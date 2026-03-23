//
//  CreatePostRequest.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


struct CreatePostRequest: Encodable {

    let caption: String
    let dishName: String
    let cuisine: String
    let calories: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
    let healthScore: Int
    let tags: String
    let image_url: String

    enum CodingKeys: String, CodingKey {
        case caption
        case dishName = "dish_name"
        case cuisine
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case healthScore = "health_score"
        case tags
        case image_url
    }
}
