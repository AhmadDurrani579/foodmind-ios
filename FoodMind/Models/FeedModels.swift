//
//  FeedModels.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI
 
// ─────────────────────────────────────
// MARK: — User Model
// ─────────────────────────────────────
struct FMUser: Identifiable {
    let id:           String
    let username:     String
    let displayName:  String
    let avatarEmoji:  String
    let location:     String
}
 
// ─────────────────────────────────────
// MARK: — Nutrition Model
// ─────────────────────────────────────
struct FMNutrition {
    let calories: Int
    let protein:  Double
    let carbs:    Double
    let fat:      Double
}
 
// ─────────────────────────────────────
// MARK: — Feed Post Model
// ─────────────────────────────────────
struct FMPost: Identifiable {
    let id:          String
    let user:        FMUser
    let dishName:    String
    let foodEmoji:   String
    let imageURL: String?
    let bgColor1:    String   // hex gradient start
    let bgColor2:    String   // hex gradient end
    let nutrition:   FMNutrition
    let tags:        [String]
    let caption:     String
    let likes:       Int
    let comments:    Int
    let timeAgo:     String
    let confidence:  Int      // MobileNet confidence %
    let styleTag:    String   // Italian, Asian, etc
    var isLiked:     Bool = false
    var isBookmarked:Bool = false
}
 
// ─────────────────────────────────────
// MARK: — Mock Data
// Replace with real API data later
// ─────────────────────────────────────

