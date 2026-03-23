//
//  FeedViewModel.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import Combine
import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var posts: [FMPost] = []
    @Published var isSharing = false
    @Published var shareSuccess = false
    @Published var errorMessage: String?

    private let repository: FeedRepositoryProtocol = FeedRepository()
    
    func loadFeed() {
        isSharing = true
        Task {
            do {
                let apiPosts = try await repository.getFeed(limit: 20, offset: 0)

                // Convert API model → UI model
                posts = apiPosts.map { FeedMapper.mapToUI($0) }
                isSharing = false
            } catch {
                print(error)
                isSharing = false
            }
        }
    }

    func shareToFeed(result: BackendScanResult, imageURL: String, caption: String) {
        isSharing = true
        Task {
            do {
                let request = CreatePostRequest(
                    caption: caption,
                    dishName: result.dish_name,
                    cuisine: result.cuisine,
                    calories: result.calories,
                    proteinG: Int(result.protein_g),
                    carbsG: Int(result.carbs_g),
                    fatG: Int(result.fat_g),
                    healthScore: result.health_score,
                    tags: result.tags.joined(separator: ","),
                    image_url: imageURL
                )
                try await repository.createPost(request)
                shareSuccess = true
                isSharing = false
                NotificationCenter.default.post(
                    name: Notification.Name("NewPostShared"),
                    object: nil
                )
                print("Shared to feed")

            } catch {

                isSharing = false
                errorMessage = error.localizedDescription
                print(" Share failed \(error)")
            }
        }
    }
}
