//
//  APIClient.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


import Foundation

class APIClient {
    
    static let shared = APIClient()
    
    private let baseURL = "https://ahmaddurrani-food-mind.hf.space"
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // Default JSON header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Endpoint specific headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Authorization token
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
//        guard 200...299 ~= http.statusCode else {
//            throw URLError(.badServerResponse)
//        }
        
        switch http.statusCode {
        case 200...299:
            break
        case 401:
            // ── Centralised auth expiry handler ──
            // Fires once here — every screen reacts automatically
            TokenManager.shared.clearToken()
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .unauthorizedAccess,
                    object: nil
                )
            }
            throw APIError.unauthorized
        case 400:
            throw APIError.badRequest
        default:
            throw APIError.serverError(http.statusCode)
        }

        
        return try JSONDecoder().decode(T.self, from: data)
    }
}


extension Notification.Name {
    static let unauthorizedAccess = Notification.Name("unauthorizedAccess")
}


enum APIError: Error {
    case unauthorized
    case badRequest
    case serverError(Int)
    case decodingError
}
