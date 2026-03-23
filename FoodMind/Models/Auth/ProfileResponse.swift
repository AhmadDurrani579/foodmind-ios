//
//  ProfileResponse.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


struct ProfileResponse: Decodable {
    let success: Bool
    let user: User
}