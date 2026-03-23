//
//  AuthViewModel.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?

    private let repository: AuthRepositoryProtocol = AuthRepository()

    func signup(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        avatar: UIImage?
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        // Perform signup
        let response = try await repository.signup(
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            password: password
        )
        user = response.user

        // Optional avatar upload
        if let avatarImage = avatar {
            let avatarURL = try await repository.uploadAvatar(image: avatarImage)
            print("Avatar uploaded:", avatarURL)
        }

        print("Signup success:", response.user)
    }
    
    func login(
        email: String,
        password: String,
    ) async throws {
        isLoading = true
        defer { isLoading = false }

        // Perform signup
        let response = try await repository.login(
            email: email,
            password: password
        )
        user = response.user

        // Optional avatar upload
        print("Signup success:", response.user)
    }
    
}
