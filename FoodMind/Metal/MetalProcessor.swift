//
//  MetalProcessor.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import Metal
import MetalKit
import CoreVideo
import UIKit
import CoreImage
import Combine

class MetalProcessor: ObservableObject {

    // ── Published ─────────────────────
    @Published var processedImage: UIImage? = nil

    // ── Metal ─────────────────────────
    private var device:        MTLDevice?
    private var commandQueue:  MTLCommandQueue?
    private var pipelineState: MTLComputePipelineState?
    private var textureCache: CVMetalTextureCache?

    // ── Timing ────────────────────────
    private let startTime = Date()

    // ── State ─────────────────────────
    private var isProcessing = false

    // ─────────────────────────────────
    // MARK: — Init
    // ─────────────────────────────────
    init() {
        setupMetal()
    }

    // ─────────────────────────────────
    // MARK: — Setup Metal
    // ─────────────────────────────────
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal not supported on this device")
            return
        }

        self.device       = device
        self.commandQueue = device.makeCommandQueue()

        // Create texture cache for fast CVPixelBuffer → MTLTexture
        CVMetalTextureCacheCreate(
            kCFAllocatorDefault,
            nil,
            device,
            nil,
            &textureCache
        )

        // Load shader function
        guard let library  = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "foodScanEffect")
        else {
            print("❌ Could not load Metal shader — check FoodScanShader.metal")
            return
        }

        do {
            pipelineState = try device.makeComputePipelineState(function: function)
            print("✅ Metal shader loaded successfully")
        } catch {
            print("❌ Metal pipeline error: \(error)")
        }
    }

    // ─────────────────────────────────
    // MARK: — Process Frame
    // Called every frame from CameraView
    // ─────────────────────────────────
    func process(
        pixelBuffer:  CVPixelBuffer,
        boundingBox:  CGRect,      // from VisionManager (normalised 0-1)
        confidence:   Float,       // from FoodClassifierManager (0-1)
        hasDetection: Bool
    ) {
        // Skip if already processing (prevents queue buildup)
        guard !isProcessing else { return }
        guard let device       = device,
              let commandQueue = commandQueue,
              let pipeline     = pipelineState
        else { return }

        isProcessing = true

        let width  = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let time   = Float(Date().timeIntervalSince(startTime))

        // ── Create textures ───────────
        let descriptor         = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width:       width,
            height:      height,
            mipmapped:   false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]

        guard let inTexture  = device.makeTexture(descriptor: descriptor),
              let outTexture = device.makeTexture(descriptor: descriptor)
        else {
            isProcessing = false
            return
        }

        // ── Copy pixel buffer to texture ──
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        if let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) {
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            inTexture.replace(
                region:      MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0,
                withBytes:   baseAddress,
                bytesPerRow: bytesPerRow
            )
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        // ── Build uniforms ────────────
        // Vision bounding box is in normalised coords
        // but Y is flipped (Vision uses bottom-left origin)
        // Metal uses top-left origin — flip Y
        var uniforms = ScanUniforms(
            boxMin:       SIMD2<Float>(
                Float(boundingBox.minX),
                Float(1.0 - boundingBox.maxY)  // flip Y
            ),
            boxMax:       SIMD2<Float>(
                Float(boundingBox.maxX),
                Float(1.0 - boundingBox.minY)  // flip Y
            ),
            confidence:   confidence,
            time:         time,
            hasDetection: hasDetection ? 1 : 0
        )

        // ── Encode and dispatch ───────
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder       = commandBuffer.makeComputeCommandEncoder()
        else {
            isProcessing = false
            return
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(inTexture,  index: 0)
        encoder.setTexture(outTexture, index: 1)
        encoder.setBytes(
            &uniforms,
            length: MemoryLayout<ScanUniforms>.stride,
            index:  0
        )

        // Dispatch threads
        let threadGroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroups    = MTLSize(
            width:  (width  + 15) / 16,
            height: (height + 15) / 16,
            depth:  1
        )
        encoder.dispatchThreadgroups(
            threadGroups,
            threadsPerThreadgroup: threadGroupSize
        )
        encoder.endEncoding()

        // ── Get result ────────────────
        commandBuffer.addCompletedHandler { [weak self] _ in
            guard let self = self else { return }

            if let image = self.textureToUIImage(outTexture) {
                DispatchQueue.main.async {
                    self.processedImage = image
                    self.isProcessing   = false
                }
            } else {
                self.isProcessing = false
            }
        }

        commandBuffer.commit()
    }

    // ─────────────────────────────────
    // MARK: — Texture To UIImage
    // ─────────────────────────────────
    private func textureToUIImage(_ texture: MTLTexture) -> UIImage? {
        let width       = texture.width
        let height      = texture.height
        let bytesPerRow = width * 4
        var bytes       = [UInt8](repeating: 0, count: bytesPerRow * height)

        texture.getBytes(
            &bytes,
            bytesPerRow: bytesPerRow,
            from:        MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )

        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let cgImage  = CGImage(
                width:             width,
                height:            height,
                bitsPerComponent:  8,
                bitsPerPixel:      32,
                bytesPerRow:       bytesPerRow,
                space:             CGColorSpaceCreateDeviceRGB(),
                bitmapInfo:        CGBitmapInfo(
                    rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue |
                              CGBitmapInfo.byteOrder32Little.rawValue
                ),
                provider:          provider,
                decode:            nil,
                shouldInterpolate: true,
                intent:            .defaultIntent
              )
        else { return nil }

        return UIImage(cgImage: cgImage)
    }

    // ─────────────────────────────────
    // MARK: — Reset
    // ─────────────────────────────────
    func reset() {
        DispatchQueue.main.async {
            self.processedImage = nil
        }
        isProcessing = false
    }
}

// ─────────────────────────────────────
// MARK: — ScanUniforms
// Must match struct in .metal file exactly
// ─────────────────────────────────────
struct ScanUniforms {
    var boxMin:       SIMD2<Float>
    var boxMax:       SIMD2<Float>
    var confidence:   Float
    var time:         Float
    var hasDetection: Int32
}
