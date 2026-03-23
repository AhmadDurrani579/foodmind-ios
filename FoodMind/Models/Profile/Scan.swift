//
//  Scan.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


import Foundation

struct Scan: Identifiable, Codable {
    let id:         String
    let user_id:    String
    let dish_name:  String
    let cuisine:    String?
    let calories:   Int?
    let protein_g:  Double?
    let carbs_g:    Double?
    let fat_g:      Double?
    let created_at: String

    // ── Computed for UI ──────────────
    var name:     String { dish_name }
    var styleTag: String { cuisine ?? "Unknown" }
    var calories_display: Int { calories ?? 0 }

    var protein: Int { Int(protein_g ?? 0) }
    var carbs:   Int { Int(carbs_g ?? 0) }
    var fat:     Int { Int(fat_g ?? 0) }

    var emoji: String {
        // Map cuisine to emoji
        switch cuisine?.lowercased() {
        case "italian":   return "🍝"
        case "american":  return "🍔"
        case "japanese":  return "🍣"
        case "chinese":   return "🥡"
        case "indian":    return "🍛"
        case "mexican":   return "🌮"
        case "healthy":   return "🥗"
        case "breakfast": return "🍳"
        default:          return "🍽️"
        }
    }

    var time: String {
        // Format created_at to readable time
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = formatter.date(from: created_at) {
            let display = RelativeDateTimeFormatter()
            display.unitsStyle = .abbreviated
            return display.localizedString(for: date, relativeTo: Date())
        }
        return created_at
    }
}
