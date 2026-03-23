//
//  User.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


struct User: Codable {

    let id: String
    let email: String
    let username: String
    let firstName: String
    let lastName: String
    let avatarURL: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
