//
//  FoodClassifier.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI
import Vision
import CoreML
import Combine

class FoodClassifierManager: ObservableObject {

    // ── Published state ───────────────
    @Published var result:    FoodClassificationResult? = nil
    @Published var isRunning: Bool = false
    @Published var error:     String? = nil

    // ── Private ───────────────────────
    private var visionModel: VNCoreMLModel?
    private let queue = DispatchQueue(
        label: "com.foodmind.classifier",
        qos: .userInitiated
    )

    // ─────────────────────────────────
    // MARK: — Init
    // ─────────────────────────────────
    init() {
        loadModel()
    }

    // ─────────────────────────────────
    // MARK: — Load Model
    // ─────────────────────────────────
    private func loadModel() {

        // ── IMPORTANT ─────────────────
        // Change "FoodClassifier" below
        // to match your .mlmodel filename
        // ──────────────────────────────

        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all // uses Neural Engine ✅

            // Try to load FoodClassifier model
            // Replace class name when you rename model
            guard let modelURL = Bundle.main.url(
                forResource: "FoodClassifier",
                withExtension: "mlmodelc"
            ) ?? Bundle.main.url(
                forResource: "FoodClassifier",
                withExtension: "mlmodel"
            ) else {
                DispatchQueue.main.async {
                    self.error = "Model file not found. Make sure FoodClassifier.mlmodel is in your project."
                }
                return
            }

            let mlModel = try MLModel(
                contentsOf: modelURL,
                configuration: config
            )
            visionModel = try VNCoreMLModel(for: mlModel)
            print("FoodClassifier loaded successfully")

        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to load model: \(error.localizedDescription)"
            }
            print("Model load error: \(error)")
        }
    }

    // ─────────────────────────────────
    // MARK: — Classify UIImage
    // Call this with any UIImage
    // ─────────────────────────────────
    func classify(image: UIImage) {
        guard let visionModel = visionModel else {
            DispatchQueue.main.async {
                self.error = "Model not loaded"
            }
            return
        }
        let targetSize = CGSize(width: 299, height: 299)
        let processImage = image.resizedForCoreML(size: targetSize) ?? image /*image.resizedForCoreML(size: targetSize) ?? image*/
        guard let cgImage = processImage.cgImage else {
            DispatchQueue.main.async {
                self.error = "Invalid image"
            }
            return
        }

        DispatchQueue.main.async {
            self.isRunning = true
            self.error     = nil
        }

        queue.async { [weak self] in
            guard let self = self else { return }

            // Create Vision request
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.isRunning = false
                        self.error = error.localizedDescription
                    }
                    return
                }

                // Parse results
                guard let observations = request.results
                    as? [VNClassificationObservation],
                    !observations.isEmpty
                else {
                    DispatchQueue.main.async {
                        self.isRunning = false
                        self.error = "No results"
                    }
                    return
                }

                // Build result
                let top = observations[0]
                let allResults = observations.prefix(5).map {
                    (label: $0.identifier, confidence: Double($0.confidence))
                }

                let result = FoodClassificationResult(
                    dishName:   top.identifier,
                    confidence: Double(top.confidence),
                    allResults: Array(allResults)
                )

                DispatchQueue.main.async {
                    self.result    = result
                    self.isRunning = false
                    print("Classified: \(result.displayName) (\(result.confidencePercent)%)")
                }
            }

            // Image should be cropped to centre
            request.imageCropAndScaleOption = .centerCrop

            // Run request
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                options: [:]
            )

            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isRunning = false
                    self.error = error.localizedDescription
                }
            }
        }
    }

    // ─────────────────────────────────
    // MARK: — Classify CVPixelBuffer
    // Used for live camera frames
    // ─────────────────────────────────
    func classify(pixelBuffer: CVPixelBuffer) {
        guard let visionModel = visionModel else { return }

        // Don't queue up requests if already running
        guard !isRunning else { return }

        DispatchQueue.main.async {
            self.isRunning = true
        }

        queue.async { [weak self] in
            guard let self = self else { return }

            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                guard let self = self else { return }

                guard let observations = request.results
                    as? [VNClassificationObservation],
                    let top = observations.first
                else {
                    DispatchQueue.main.async { self.isRunning = false }
                    return
                }

                let result = FoodClassificationResult(
                    dishName:   top.identifier,
                    confidence: Double(top.confidence),
                    allResults: observations.prefix(5).map {
                        (label: $0.identifier, confidence: Double($0.confidence))
                    }
                )

                DispatchQueue.main.async {
                    self.result    = result
                    self.isRunning = false
                }
            }

            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                options: [:]
            )

            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { self.isRunning = false }
            }
        }
    }

    // ─────────────────────────────────
    // MARK: — Reset
    // ─────────────────────────────────
    func reset() {
        DispatchQueue.main.async {
            self.result    = nil
            self.isRunning = false
            self.error     = nil
        }
    }
}


extension UIImage {
    func resizedForCoreML(size: CGSize = CGSize(width: 299, height: 299)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

