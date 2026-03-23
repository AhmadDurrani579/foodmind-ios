//
//  TokenManager.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//

import Foundation
class TokenManager {

    static let shared = TokenManager()

    private init() {}

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "auth_token")
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }
}
