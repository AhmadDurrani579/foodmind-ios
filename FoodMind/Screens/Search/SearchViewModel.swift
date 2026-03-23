//
//  SearchViewModel.swift
//  FoodMind
//
//  Created by Ahmad on 23/03/2026.
//

import SwiftUI
import Combine

// ── Update SearchViewModel to use your existing setup ──

@MainActor
class SearchViewModel: ObservableObject {
 
    @Published var posts:            [FMPost]           = []
    @Published var filteredPosts:    [FMPost]           = []
    @Published var trendingTags:     [TagCount]         = []
    @Published var isLoading:        Bool               = false
    @Published var searchText:       String             = ""
    @Published var selectedTag:      String?            = nil
    @Published var nutritionSummary: NutritionSummary?  = nil
 
    private let repository: FeedRepositoryProtocol = FeedRepository()
 
    struct TagCount: Identifiable {
        let id    = UUID()
        let tag:   String
        let count: Int
    }
 
    struct NutritionSummary {
        let dishName:  String
        let avgCal:    Int
        let avgPro:    Double
        let avgCarbs:  Double
        let avgFat:    Double
        let postCount: Int
    }
 
    // ─────────────────────────────────
    // MARK: — Load Posts
    // ─────────────────────────────────
    func loadPosts() {
        isLoading = true
        Task {
            do {
                let apiPosts  = try await repository.getFeed(limit: 100, offset: 0)
                posts         = apiPosts.map { FeedMapper.mapToUI($0) }
                filteredPosts = posts
                trendingTags  = extractTrendingTags(from: posts)
            } catch {
                print("SearchViewModel error: \(error)")
            }
            isLoading = false
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Search
    // ─────────────────────────────────
    func search(query: String) {
        selectedTag = nil
 
        guard !query.isEmpty else {
            filteredPosts    = posts
            nutritionSummary = nil
            return
        }
 
        let q = query.lowercased()
        filteredPosts = posts.filter { post in
            post.dishName.lowercased().contains(q)      ||
            post.styleTag.lowercased().contains(q)      ||
            post.tags.joined().lowercased().contains(q) ||
            post.caption.lowercased().contains(q)
        }
 
        if !filteredPosts.isEmpty {
            let count    = filteredPosts.count
            let avgCal   = filteredPosts.map { $0.nutrition.calories }.reduce(0, +) / count
            let avgPro   = filteredPosts.map { $0.nutrition.protein }.reduce(0.0, +)  / Double(count)
            let avgCarbs = filteredPosts.map { $0.nutrition.carbs }.reduce(0.0, +)    / Double(count)
            let avgFat   = filteredPosts.map { $0.nutrition.fat }.reduce(0.0, +)      / Double(count)
 
            nutritionSummary = NutritionSummary(
                dishName:  query.capitalized,
                avgCal:    avgCal,
                avgPro:    avgPro,
                avgCarbs:  avgCarbs,
                avgFat:    avgFat,
                postCount: count
            )
        } else {
            nutritionSummary = nil
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Filter By Tag
    // ─────────────────────────────────
    func filterByTag(_ tag: String) {
        if selectedTag == tag {
            selectedTag      = nil
            filteredPosts    = posts
            nutritionSummary = nil
            return
        }
        selectedTag      = tag
        searchText       = ""
        nutritionSummary = nil
        filteredPosts    = posts.filter {
            $0.tags.joined().lowercased().contains(tag.lowercased())
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Extract Trending Tags
    // ─────────────────────────────────
    private func extractTrendingTags(from posts: [FMPost]) -> [TagCount] {
        var counts: [String: Int] = [:]
        for post in posts {
            post.tags.forEach { counts[$0, default: 0] += 1 }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { TagCount(tag: $0.key, count: $0.value) }
    }
}
