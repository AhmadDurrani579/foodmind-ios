//
//  CameraPreviewView.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import CoreML
import Vision
import UIKit
import Combine

// ─────────────────────────────────────
// MARK: — Classification Result
// ─────────────────────────────────────
struct FoodClassificationResult {
    let dishName:    String      // e.g. "pizza"
    let confidence:  Double      // 0.0 - 1.0
    let allResults:  [(label: String, confidence: Double)]

    // Formatted dish name for display
    var displayName: String {
        dishName
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    // Confidence as percentage string
    var confidencePercent: Int {
        Int(confidence * 100)
    }

    // Confidence level
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.85...: return .high
        case 0.60...: return .medium
        default:      return .low
        }
    }
}

enum ConfidenceLevel {
    case high    // > 85% — green
    case medium  // 60-85% — yellow
    case low     // < 60% — red

    var color: String {
        switch self {
        case .high:   return "8DB87A"  // FMColors.green
        case .medium: return "F2C94C"  // FMColors.yellow
        case .low:    return "D95F4B"  // FMColors.red
        }
    }

    var label: String {
        switch self {
        case .high:   return "High confidence"
        case .medium: return "Medium confidence"
        case .low:    return "Low confidence"
        }
    }
}

