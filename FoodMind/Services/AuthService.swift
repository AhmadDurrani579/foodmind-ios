//
//  AuthService.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


class AuthService {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }

    func signup(
        email: String,
        password: String
    ) async throws -> User {

        return try await repository.signup(
            email: email,
            password: password
        )
    }
}
