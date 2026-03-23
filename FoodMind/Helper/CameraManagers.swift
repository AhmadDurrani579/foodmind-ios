//
//  CameraManagers.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import AVFoundation
import UIKit
import Combine

class CameraManager: NSObject, ObservableObject {

    // ── Published ─────────────────────
    @Published var isAuthorized: Bool = false
    @Published var error: CameraError? = nil

    // ── Session ───────────────────────
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(
        label: "com.foodmind.camera.session",
        qos: .userInitiated
    )

    // ── Frame callback ────────────────
    // Called every frame with pixel buffer
    var onFrame: ((CVPixelBuffer) -> Void)?

    // ── Camera position ───────────────
    private var currentPosition: AVCaptureDevice.Position = .back

    // ─────────────────────────────────
    // MARK: — Setup
    // ─────────────────────────────────
    func setup() {
        checkAuthorization()
    }

    private func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.isAuthorized = true }
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                }
                if granted { self.setupSession() }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.error = .permissionDenied
            }
        @unknown default:
            break
        }
    }

    // ─────────────────────────────────
    // MARK: — Configure Session
    // ─────────────────────────────────
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Add video input
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: self.currentPosition
            ),
            let input = try? AVCaptureDeviceInput(device: device),
            self.session.canAddInput(input) else {
                DispatchQueue.main.async {
                    self.error = .setupFailed
                }
                return
            }

            self.session.addInput(input)

            // Add video output
            self.videoOutput.setSampleBufferDelegate(
                self,
                queue: DispatchQueue(
                    label: "com.foodmind.camera.frames",
                    qos: .userInitiated
                )
            )
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String:
                    kCVPixelFormatType_32BGRA
            ]

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            self.session.commitConfiguration()
        }
    }

    // ─────────────────────────────────
    // MARK: — Start / Stop
    // ─────────────────────────────────
    func start() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // ─────────────────────────────────
    // MARK: — Flip Camera
    // ─────────────────────────────────
    func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()

            // Remove existing input
            self.session.inputs.forEach {
                self.session.removeInput($0)
            }

            // Switch position
            self.currentPosition = self.currentPosition == .back
                ? .front
                : .back

            // Add new input
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: self.currentPosition
            ),
            let input = try? AVCaptureDeviceInput(device: device),
            self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)
            self.session.commitConfiguration()
        }
    }

    // ─────────────────────────────────
    // MARK: — Toggle Flash
    // ─────────────────────────────────
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
        device.hasTorch else { return }

        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }
}

// ─────────────────────────────────────
// MARK: — AVCaptureVideoDataOutputSampleBufferDelegate
// Called for every camera frame
// ─────────────────────────────────────
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        // Pass frame to classifier
        onFrame?(pixelBuffer)
    }
}

// ─────────────────────────────────────
// MARK: — Camera Error
// ─────────────────────────────────────
enum CameraError: Error, LocalizedError {
    case permissionDenied
    case setupFailed
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera access denied. Please enable in Settings."
        case .setupFailed:
            return "Camera setup failed."
        case .notAvailable:
            return "Camera not available on this device."
        }
    }
}
