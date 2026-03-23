//
//  FeedRepositoryProtocol.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import SwiftUI

protocol FeedRepositoryProtocol {
    func createPost(_ request: CreatePostRequest) async throws
    func getFeed(limit: Int, offset: Int) async throws -> [FeedPost]

}

class FeedRepository: FeedRepositoryProtocol {
    func createPost(_ request: CreatePostRequest) async throws {

        let endpoint = CreatePostEndpoint(request: request)

        _ = try await APIClient.shared.request(endpoint) as EmptyResponse
    }
    
    func getFeed(limit: Int = 20, offset: Int = 0) async throws -> [FeedPost] {
        let endpoint = FeedEndpoint(limit: limit, offset: offset)

        let posts: [FeedPost] = try await APIClient.shared.request(endpoint)

        return posts
    }
}


struct EmptyResponse: Decodable {}
