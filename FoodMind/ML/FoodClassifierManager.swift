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
    private var predictionBuffer: [(label: String, confidence: Double)] = []
    private let bufferSize = 5  // average last 5 predictions

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
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all

            // Use auto-generated class directly
            // No need for Bundle.main.url
            let model = try FoodClassifier(configuration: config)
            visionModel = try VNCoreMLModel(for: model.model)
            print(" FoodClassifier loaded - 101 classes")

        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to load: \(error.localizedDescription)"
            }
            print(" Model error: \(error)")
        }
    }
    // ─────────────────────────────────
    // MARK: — Classify UIImage
    // Call this with any UIImage
    // ─────────────────────────────────
    func classify(image: UIImage) {
        guard let visionModel = visionModel else {
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return }
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

        DispatchQueue.main.async {[weak self ] in
            self?.isRunning = true
            self?.error     = nil
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

                let result = self.smoothedResult(from: observations)
                if result.confidence > 0.40 {
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else {return }
                        self.result    = result
                        self.isRunning = false
                        print("Classified: \(result.displayName) (\(result.confidencePercent)%)")
                    }
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
    
    func classifyWithCrop(
        pixelBuffer: CVPixelBuffer,
        cropRect: CGRect  // from VisionManager bounding box
    ) {
        guard let visionModel = visionModel else { return }
        guard !isRunning else { return }

        DispatchQueue.main.async { self.isRunning = true }

        queue.async { [weak self] in
            guard let self = self else { return }

            let request = VNCoreMLRequest(
                model: visionModel
            ) { [weak self] request, error in
                guard let self = self else { return }

                guard let observations = request.results
                    as? [VNClassificationObservation],
                    let top = observations.first
                else {
                    DispatchQueue.main.async {
                        self.isRunning = false
                    }
                    return
                }

                let result = FoodClassificationResult(
                    dishName:   top.identifier,
                    confidence: Double(top.confidence),
                    allResults: observations.prefix(5).map {
                        (label: $0.identifier,
                         confidence: Double($0.confidence))
                    }
                )

                DispatchQueue.main.async {
                    self.result    = result
                    self.isRunning = false
                }
            }

            // Crop to food region
            request.regionOfInterest = cropRect
            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                options: [:]
            )

            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isRunning = false
                }
            }
        }
    }
    
    private func smoothedResult(
        from observations: [VNClassificationObservation]
    ) -> FoodClassificationResult {

        guard let top = observations.first else {
            return FoodClassificationResult(
                dishName:   "unknown",
                confidence: 0,
                allResults: []
            )
        }

        // Add to buffer
        predictionBuffer.append((
            label:      top.identifier,
            confidence: Double(top.confidence)
        ))

        // Keep only last N predictions
        if predictionBuffer.count > bufferSize {
            predictionBuffer.removeFirst()
        }

        // Find most common label
        let labelCounts = Dictionary(
            grouping: predictionBuffer,
            by: { $0.label }
        )

        let mostCommon = labelCounts.max {
            $0.value.count < $1.value.count
        }

        let winningLabel = mostCommon?.key ?? top.identifier

        // Average confidence — broken into steps
        let winningPredictions = labelCounts[winningLabel] ?? []
        let totalConfidence    = winningPredictions.map(\.confidence).reduce(0, +)
        let count              = Double(winningPredictions.count)
        let avgConfidence      = count > 0
            ? totalConfidence / count
            : Double(top.confidence)

        return FoodClassificationResult(
            dishName:   winningLabel,
            confidence: avgConfidence,
            allResults: observations.prefix(5).map {
                (label:      $0.identifier,
                 confidence: Double($0.confidence))
            }
        )
    }

    // ─────────────────────────────────
    // MARK: — Reset
    // ─────────────────────────────────
    func reset() {
        predictionBuffer = []
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

