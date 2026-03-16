//
//  SearchView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI
 
// ─────────────────────────────────────
// MARK: — Search Models
// ─────────────────────────────────────
struct FMSearchUser: Identifiable {
    let id:          String
    let username:    String
    let displayName: String
    let avatar:      String
    let location:    String
    let avgCalories: Int
    let scans:       Int
    let topDish:     String
    let topDishEmoji:String
    var isFollowing: Bool
}
 
struct FMTrendingDish: Identifiable {
    let id:       String
    let emoji:    String
    let name:     String
    let scans:    Int
    let calories: Int
    let tag:      String
    let tagColor: String
}
 
// ─────────────────────────────────────
// MARK: — Mock Data
// ─────────────────────────────────────
extension FMSearchUser {
    static let mockUsers: [FMSearchUser] = [
        FMSearchUser(
            id: "u1",
            username: "sara.eats",
            displayName: "Sara Ahmed",
            avatar: "👩",
            location: "London",
            avgCalories: 1640,
            scans: 89,
            topDish: "Grilled Salmon",
            topDishEmoji: "🐟",
            isFollowing: true
        ),
        FMSearchUser(
            id: "u2",
            username: "mike.chef",
            displayName: "Mike Chen",
            avatar: "👨🏽",
            location: "Manchester",
            avgCalories: 2340,
            scans: 124,
            topDish: "Ramen",
            topDishEmoji: "🍜",
            isFollowing: false
        ),
        FMSearchUser(
            id: "u3",
            username: "luna.fit",
            displayName: "Luna Park",
            avatar: "👩🏻",
            location: "Birmingham",
            avgCalories: 1480,
            scans: 67,
            topDish: "Sushi",
            topDishEmoji: "🍱",
            isFollowing: true
        ),
        FMSearchUser(
            id: "u4",
            username: "jay.real",
            displayName: "Jay Williams",
            avatar: "🧑🏾",
            location: "Leeds",
            avgCalories: 2890,
            scans: 43,
            topDish: "Burger",
            topDishEmoji: "🍔",
            isFollowing: false
        ),
        FMSearchUser(
            id: "u5",
            username: "ava.wellness",
            displayName: "Ava Johnson",
            avatar: "👩‍🦱",
            location: "Bristol",
            avgCalories: 1320,
            scans: 156,
            topDish: "Acai Bowl",
            topDishEmoji: "🫐",
            isFollowing: false
        ),
        FMSearchUser(
            id: "u6",
            username: "kai.food",
            displayName: "Kai Tanaka",
            avatar: "🧑🏻",
            location: "Edinburgh",
            avgCalories: 1980,
            scans: 78,
            topDish: "Ramen",
            topDishEmoji: "🍜",
            isFollowing: false
        ),
        FMSearchUser(
            id: "u7",
            username: "priya.bites",
            displayName: "Priya Sharma",
            avatar: "👩🏾",
            location: "Leicester",
            avgCalories: 1740,
            scans: 92,
            topDish: "Biryani",
            topDishEmoji: "🍛",
            isFollowing: true
        )
    ]
}
 
extension FMTrendingDish {
    static let mockTrending: [FMTrendingDish] = [
        FMTrendingDish(
            id: "d1",
            emoji: "🍕",
            name: "Margherita Pizza",
            scans: 2341,
            calories: 890,
            tag: "Italian",
            tagColor: "E8834A"
        ),
        FMTrendingDish(
            id: "d2",
            emoji: "🥗",
            name: "Chicken Salad",
            scans: 1892,
            calories: 380,
            tag: "Healthy",
            tagColor: "8DB87A"
        ),
        FMTrendingDish(
            id: "d3",
            emoji: "🍜",
            name: "Ramen Bowl",
            scans: 1654,
            calories: 620,
            tag: "Japanese",
            tagColor: "5DADE2"
        ),
        FMTrendingDish(
            id: "d4",
            emoji: "🍔",
            name: "Beef Burger",
            scans: 1423,
            calories: 1240,
            tag: "American",
            tagColor: "E07A55"
        ),
        FMTrendingDish(
            id: "d5",
            emoji: "🍛",
            name: "Chicken Biryani",
            scans: 1187,
            calories: 720,
            tag: "Indian",
            tagColor: "F2C94C"
        ),
        FMTrendingDish(
            id: "d6",
            emoji: "🍱",
            name: "Salmon Sushi",
            scans: 934,
            calories: 520,
            tag: "Japanese",
            tagColor: "5DADE2"
        )
    ]
}


struct SearchView: View {
 
    @State private var searchText       = ""
    @State private var users            = FMSearchUser.mockUsers
    @State private var trendingDishes   = FMTrendingDish.mockTrending
    @State private var selectedFilter   = "All"
    @FocusState private var searchFocused: Bool
 
    let filters = ["All", "Following", "Healthy", "Italian", "Asian", "Indian"]
 
    // Filtered users based on search text
    var filteredUsers: [FMSearchUser] {
        if searchText.isEmpty {
            if selectedFilter == "All"       { return users }
            if selectedFilter == "Following" { return users.filter { $0.isFollowing } }
            return users
        }
        return users.filter {
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.topDish.localizedCaseInsensitiveContains(searchText)
        }
    }
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                // ── Header ──────────────────
                SearchHeader(
                    searchText:     $searchText,
                    searchFocused:  $searchFocused
                )
 
                // ── Filter Pills ────────────
                FilterPillsRow(
                    filters:        filters,
                    selectedFilter: $selectedFilter
                )
 
                // ── Content ─────────────────
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
 
                        // Show trending when not searching
                        if searchText.isEmpty {
 
                            // Trending dishes
                            TrendingDishesSection(dishes: trendingDishes)
 
                            // Suggested users
                            SuggestedUsersSection(
                                users:   $users,
                                filter:  selectedFilter
                            )
 
                        } else {
                            // Search results
                            SearchResultsSection(users: $users, filtered: filteredUsers)
                        }
 
                        Color.clear.frame(height: 90)
                    }
                }
            }
        }
        .onTapGesture {
            searchFocused = false
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — Search Header
// ─────────────────────────────────────
private struct SearchHeader: View {
 
    @Binding var searchText:    String
    @FocusState.Binding var searchFocused: Bool
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
 
            Text("Discover")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(FMColors.cream)
 
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(
                        searchFocused
                            ? FMColors.green
                            : FMColors.cream.opacity(0.3)
                    )
 
                TextField("Search people, dishes...", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundColor(FMColors.cream)
                    .focused($searchFocused)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
 
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(FMColors.cream.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(FMColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        searchFocused
                            ? FMColors.green.opacity(0.4)
                            : FMColors.border,
                        lineWidth: searchFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: searchFocused)
        }
        .padding(.horizontal, 18)
        .padding(.top, 58)
        .padding(.bottom, 12)
        .background(FMColors.background)
        .overlay(
            Rectangle()
                .fill(FMColors.border2)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}
 
// ─────────────────────────────────────
// MARK: — Filter Pills Row
// ─────────────────────────────────────
private struct FilterPillsRow: View {
 
    let filters: [String]
    @Binding var selectedFilter: String
 
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    FilterPill(
                        label:      filter,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .background(FMColors.background)
        .overlay(
            Rectangle()
                .fill(FMColors.border2)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// ─────────────────────────────────────
// MARK: — Trending Dishes Section
// ─────────────────────────────────────
private struct TrendingDishesSection: View {
 
    let dishes: [FMTrendingDish]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
 
            // Section header
            HStack {
                Text("🔥 TRENDING TODAY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
                Spacer()
                Text("See all")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.green)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
 
            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dishes) { dish in
                        TrendingDishCard(dish: dish)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 4)
            }
        }
        .padding(.bottom, 8)
    }
}

// ─────────────────────────────────────
// MARK: — Suggested Users Section
// ─────────────────────────────────────
private struct SuggestedUsersSection: View {
 
    @Binding var users:  [FMSearchUser]
    let filter: String
 
    var filtered: [FMSearchUser] {
        switch filter {
        case "Following": return users.filter { $0.isFollowing }
        default:          return users
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
 
            HStack {
                Text("PEOPLE TO FOLLOW")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
 
            ForEach(filtered.indices, id: \.self) { index in
                if let userIndex = users.firstIndex(where: {
                    $0.id == filtered[index].id
                }) {
                    UserRow(user: $users[userIndex])
                        .padding(.horizontal, 18)
                }
            }
        }
        .padding(.bottom, 8)
    }
}
 
// ─────────────────────────────────────
// MARK: — Search Results Section
// ─────────────────────────────────────
private struct SearchResultsSection: View {
 
    @Binding var users:    [FMSearchUser]
    let filtered: [FMSearchUser]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
 
            HStack {
                Text("\(filtered.count) RESULTS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
 
            if filtered.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(FMColors.cream.opacity(0.15))
                    Text("No results found")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(FMColors.cream.opacity(0.4))
                    Text("Try searching by name or dish")
                        .font(.system(size: 13))
                        .foregroundColor(FMColors.cream25)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
 
            } else {
                ForEach(filtered.indices, id: \.self) { index in
                    if let userIndex = users.firstIndex(where: {
                        $0.id == filtered[index].id
                    }) {
                        UserRow(user: $users[userIndex])
                            .padding(.horizontal, 18)
                    }
                }
            }
        }
    }
}
