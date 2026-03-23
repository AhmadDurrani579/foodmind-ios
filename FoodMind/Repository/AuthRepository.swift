//
//  AuthRepository.swift
//  FoodMind
//  Created by Ahmad on 17/03/2026.
//


import Foundation
import UIKit

protocol AuthRepositoryProtocol {
    
    func signup(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String
    ) async throws -> AuthResponse
    
    func login(
        email: String,
        password: String
    ) async throws -> AuthResponse
    
    func uploadAvatar(image: UIImage) async throws -> String
    
    func getProfile() async throws -> User
}

class AuthRepository: AuthRepositoryProtocol {
    
    func signup(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String
    ) async throws -> AuthResponse {
        
        let request = SignupRequest(
            email: email,
            username: username,
            first_name: firstName,
            last_name: lastName,
            password: password
        )
        
        let endpoint = SignupEndpoint(request: request)
        
        let response: AuthResponse = try await APIClient.shared.request(endpoint)
        
        // Save token for future requests
        TokenManager.shared.saveToken(response.access_token)
        
        return response
    }
    
    func login(
        email: String,
        password: String
    ) async throws -> AuthResponse {
        
        let request = LoginRequest(
            email: email,
            password: password
        )
        
        let endpoint = LoginEndpoint(request: request)
        
        let response: AuthResponse = try await APIClient.shared.request(endpoint)
        
        TokenManager.shared.saveToken(response.access_token)
        
        return response
    }
    
    
    func uploadAvatar(image: UIImage) async throws -> String {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let boundary = UUID().uuidString
        
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        let endpoint = UploadAvatarEndpoint(
            bodyData: body,
            boundary: boundary
        )
        let response: AvatarUploadResponse =
        try await APIClient.shared.request(endpoint)
        
        return response.avatar_url
    }
    
    func getProfile() async throws -> User {
        
        let endpoint = ProfileEndpoint()
        let response: ProfileResponse =
        try await APIClient.shared.request(endpoint)
        return response.user
    }
}
