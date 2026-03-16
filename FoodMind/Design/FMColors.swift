//
//  FMColors.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//


import SwiftUI

// ─────────────────────────────────────
// MARK: — Color Helper
// ─────────────────────────────────────
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ─────────────────────────────────────
// MARK: — App Colours
// ─────────────────────────────────────
struct FMColors {
    static let background = Color(hex: "0C0D09")
    static let surface    = Color(hex: "141510")
    static let surface2   = Color(hex: "1C1D17")
    static let green      = Color(hex: "8DB87A")
    static let orange     = Color(hex: "E8834A")
    static let yellow     = Color(hex: "F2C94C")
    static let cream      = Color(hex: "F5EDD6")
    static let red        = Color(hex: "D95F4B")

    static let cream50    = Color(hex: "F5EDD6").opacity(0.5)
    static let cream25    = Color(hex: "F5EDD6").opacity(0.25)
    static let cream15    = Color(hex: "F5EDD6").opacity(0.15)

    static let border     = Color.white.opacity(0.07)
    static let border2    = Color.white.opacity(0.04)
}
