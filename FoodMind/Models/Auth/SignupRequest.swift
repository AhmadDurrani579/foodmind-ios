//
//  SignupRequest.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


struct SignupRequest: Codable {
    let email: String
    let username: String
    let first_name: String
    let last_name: String
    let password: String
}

