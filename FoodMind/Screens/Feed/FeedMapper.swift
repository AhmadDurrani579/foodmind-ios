//
//  FeedMapper.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


import Foundation

struct FeedMapper {

    static func mapToUI(_ post: FeedPost) -> FMPost {

        FMPost(
            id: post.id,

            user: FMUser(
                id: post.user_id,
                username: post.username,
                displayName: post.first_name,
                avatarEmoji: "🍽️",
                location: ""
            ),
            dishName: post.dish_name,
            foodEmoji: "🍕",
            imageURL: post.image_url,

            bgColor1: "#2E7D32",
            bgColor2: "#1B5E20",

            nutrition: FMNutrition(
                calories: post.calories,
                protein: Double(post.protein_g),
                carbs: Double(post.carbs_g),
                fat: Double(post.fat_g)
            ),

            tags: post.tags
                .split(separator: ",")
                .map { String($0) },

            caption: post.caption,

            likes: post.likes_count,

            comments: post.comments_count,

            timeAgo: "now",

            confidence: post.health_score,

            styleTag: post.cuisine
        )
    }
}
