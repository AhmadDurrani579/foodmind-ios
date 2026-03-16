//
//  PasswordStrength.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

enum PasswordStrength: Int, CaseIterable {
    case weak   = 1
    case medium = 2
    case strong = 3

    var label: String {
        switch self {
        case .weak:   return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak:   return Color(hex: "D95F4B")
        case .medium: return Color(hex: "F2C94C")
        case .strong: return Color(hex: "8DB87A")
        }
    }
}
