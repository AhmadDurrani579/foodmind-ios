//
//  AuthResponse.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let user: User
}