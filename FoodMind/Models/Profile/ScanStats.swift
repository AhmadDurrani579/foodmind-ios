//
//  ScanStats.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


struct ScanStats: Decodable {

    let totalScans: Int
    let avgCalories: Double
    let avgProtein: Double
    let avgCarbs: Double
    let avgFat: Double
    let totalThisWeek: Int

    enum CodingKeys: String, CodingKey {
        case totalScans = "total_scans"
        case avgCalories = "avg_calories"
        case avgProtein = "avg_protein"
        case avgCarbs = "avg_carbs"
        case avgFat = "avg_fat"
        case totalThisWeek = "total_this_week"
    }
}