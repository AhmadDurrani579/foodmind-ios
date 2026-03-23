//
//  FeedPost.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


import Foundation

struct FeedPost: Decodable, Identifiable {

    let id: String
    let user_id: String
    let caption: String
    let image_url: String?
    let dish_name: String
    let cuisine: String
    let calories: Int
    let protein_g: Int
    let carbs_g: Int
    let fat_g: Int
    let health_score: Int
    let tags: String
    let likes_count: Int
    let comments_count: Int
    let created_at: String
    let username: String
    let first_name: String
    let avatar_url: String?
}
