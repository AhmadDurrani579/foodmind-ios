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
extension FMPost {
    static let mockFeed: [FMPost] = [
 
        FMPost(
            id: "1",
            user: FMUser(
                id: "u1",
                username: "sara.eats",
                displayName: "Sara Ahmed",
                avatarEmoji: "👩",
                location: "London"
            ),
            dishName: "Grilled Chicken Salad",
            foodEmoji: "🥗",
            bgColor1: "0e1a0a",
            bgColor2: "1a1208",
            nutrition: FMNutrition(
                calories: 380,
                protein: 42,
                carbs: 12,
                fat: 9
            ),
            tags: ["✅ High protein", "🥬 Low carb", "📖 Recipe"],
            caption: "meal prep Sunday sorted 💪 App got everything right first try",
            likes: 234,
            comments: 18,
            timeAgo: "2 min ago",
            confidence: 96,
            styleTag: "Healthy"
        ),
 
        FMPost(
            id: "2",
            user: FMUser(
                id: "u2",
                username: "mike.chef",
                displayName: "Mike Chen",
                avatarEmoji: "👨🏽",
                location: "Manchester"
            ),
            dishName: "Margherita Pizza",
            foodEmoji: "🍕",
            bgColor1: "1a0e08",
            bgColor2: "120e08",
            nutrition: FMNutrition(
                calories: 890,
                protein: 31,
                carbs: 98,
                fat: 34
            ),
            tags: ["⚠️ High calorie", "🍕 Italian", "📖 Recipe"],
            caption: "no regrets whatsoever 😅🍕 worth every calorie",
            likes: 891,
            comments: 67,
            timeAgo: "1 hr ago",
            confidence: 98,
            styleTag: "Italian"
        ),
 
        FMPost(
            id: "3",
            user: FMUser(
                id: "u3",
                username: "luna.fit",
                displayName: "Luna Park",
                avatarEmoji: "👩🏻",
                location: "Birmingham"
            ),
            dishName: "Salmon Sushi Platter",
            foodEmoji: "🍱",
            bgColor1: "0a0e1a",
            bgColor2: "081018",
            nutrition: FMNutrition(
                calories: 520,
                protein: 38,
                carbs: 64,
                fat: 12
            ),
            tags: ["🐟 High omega-3", "🍣 Japanese", "📖 Recipe"],
            caption: "Friday treat 🍣 FoodMind nailed the calorie count",
            likes: 445,
            comments: 32,
            timeAgo: "3 hr ago",
            confidence: 94,
            styleTag: "Japanese"
        ),
 
        FMPost(
            id: "4",
            user: FMUser(
                id: "u4",
                username: "jay.real",
                displayName: "Jay Williams",
                avatarEmoji: "🧑🏾",
                location: "Leeds"
            ),
            dishName: "Beef Burger & Fries",
            foodEmoji: "🍔",
            bgColor1: "1a0e0a",
            bgColor2: "140a06",
            nutrition: FMNutrition(
                calories: 1240,
                protein: 48,
                carbs: 112,
                fat: 58
            ),
            tags: ["🔥 Cheat day", "🍔 American", "📖 Recipe"],
            caption: "cheat day activated 🍔🍟 zero regrets",
            likes: 1203,
            comments: 94,
            timeAgo: "5 hr ago",
            confidence: 97,
            styleTag: "American"
        ),
 
        FMPost(
            id: "5",
            user: FMUser(
                id: "u5",
                username: "ava.wellness",
                displayName: "Ava Johnson",
                avatarEmoji: "👩‍🦱",
                location: "Bristol"
            ),
            dishName: "Acai Bowl",
            foodEmoji: "🫐",
            bgColor1: "0e0a1a",
            bgColor2: "0a0814",
            nutrition: FMNutrition(
                calories: 340,
                protein: 8,
                carbs: 62,
                fat: 7
            ),
            tags: ["💜 Antioxidants", "🌱 Vegan", "📖 Recipe"],
            caption: "morning routine ✨ obsessed with this acai bowl",
            likes: 678,
            comments: 41,
            timeAgo: "8 hr ago",
            confidence: 91,
            styleTag: "Healthy"
        )
    ]
}
