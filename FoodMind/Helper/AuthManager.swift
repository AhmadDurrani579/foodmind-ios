//
//  AuthManager.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//

import Foundation
import Combine

@MainActor
class AuthManager: ObservableObject {

    @Published var isLoggedIn: Bool = false

    init() {
        checkLogin()
    }

    func checkLogin() {
        isLoggedIn = TokenManager.shared.getToken() != nil
    }

    func logout() {
        TokenManager.shared.clearToken()
        isLoggedIn = false
    }
}
