//
//  VisionManager.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//


import Vision
import UIKit
import Combine

class VisionManager: ObservableObject {

    // ── Published ─────────────────────
    @Published var plateDetected:   Bool    = false
    @Published var plateDistance:   PlateDistance = .unknown
    @Published var plateBoundingBox: CGRect = .zero

    // ── Private ───────────────────────
    private let queue = DispatchQueue(
        label: "com.foodmind.vision",
        qos: .userInitiated
    )

    // ─────────────────────────────────
    // MARK: — Detect Plate / Food
    // ─────────────────────────────────
    func detectPlate(in pixelBuffer: CVPixelBuffer) {

        // Use saliency to find
        // the most prominent object
        let request = VNGenerateAttentionBasedSaliencyImageRequest()

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            options: [:]
        )

        queue.async { [weak self] in
            guard let self = self else { return }

            do {
                try handler.perform([request])

                guard let result = request.results?.first
                    as? VNSaliencyImageObservation
                else { return }

                // Get salient objects bounding boxes
                let salientObjects = result.salientObjects ?? []

                if let largest = salientObjects.max(
                    by: {
                        let area0 = $0.boundingBox.width * $0.boundingBox.height
                        let area1 = $1.boundingBox.width * $1.boundingBox.height
                        return area0 < area1 // Tell Swift which one is smaller
                    })
                {
                    let box  = largest.boundingBox
                    let area = box.width * box.height

                    let distance: PlateDistance
                    if area < 0.10 {
                        distance = .tooFar       // < 10% of frame
                    } else if area < 0.25 {
                        distance = .moveCloser   // 10-25% of frame
                    } else if area > 0.90 {
                        distance = .tooClose     // > 90% of frame
                    } else {
                        distance = .perfect      // 25-90% = good ✅
                    }

                    DispatchQueue.main.async {
                        self.plateDetected    = true
                        self.plateDistance    = distance
                        self.plateBoundingBox = box
                    }

                } else {
                    DispatchQueue.main.async {
                        self.plateDetected = false
                        self.plateDistance = .unknown
                    }
                }
            } catch {
                print("Vision error: \(error)")
            }
        }
    }
}

// ─────────────────────────────────────
// MARK: — Plate Distance
// ─────────────────────────────────────
enum PlateDistance {
    case tooFar
    case moveCloser
    case perfect
    case tooClose
    case unknown

    var message: String {
        switch self {
        case .tooFar:     return "Move closer to the food"
        case .moveCloser: return "A little closer..."
        case .perfect:    return "" // silent when perfect
        case .tooClose:   return "Move back a little"
        case .unknown:    return "Point at your food"
        }
    }

    var icon: String {
        switch self {
        case .tooFar:     return "arrow.down.circle"
        case .moveCloser: return "arrow.down.circle"
        case .perfect:    return "checkmark.circle"
        case .tooClose:   return "arrow.up.circle"
        case .unknown:    return "viewfinder"
        }
    }

    var color: String {
        switch self {
        case .perfect:    return "8DB87A" // green
        case .moveCloser: return "F2C94C" // yellow
        case .tooFar:     return "E8834A" // orange
        case .tooClose:   return "D95F4B" // red
        case .unknown:    return "F5EDD6" // cream
        }
    }

    var shouldClassify: Bool {
        self == .perfect || self == .moveCloser
    }
}
