//
//  SearchView.swift
//  FoodMind
//
//  Screens/Search/SearchView.swift
//

import SwiftUI
import Combine

// ─────────────────────────────────────
// MARK: — SearchView
// ─────────────────────────────────────
struct SearchView: View {
 
    @StateObject private var viewModel = SearchViewModel()
    @FocusState  private var focused:   Bool
 
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                // ── Search Bar ────────────────
                searchBar
                    .padding(.top, 16)
                    .padding(.bottom, 4)
 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
 
                        if viewModel.searchText.isEmpty &&
                           viewModel.selectedTag == nil {
 
                            // ── Trending ──────────────
                            if !viewModel.trendingTags.isEmpty {
                                trendingSection
                                    .padding(.top, 12)
                            }
 
                            // ── Explore Header ────────
                            sectionHeader(
                                title:    "Explore",
                                subtitle: "\(viewModel.posts.count) scans"
                            )
 
                        } else {
 
                            // ── Nutrition Card ────────
                            if let s = viewModel.nutritionSummary {
                                nutritionCard(s)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)
                                    .padding(.bottom, 4)
                            }
 
                            // ── Results Header ────────
                            sectionHeader(
                                title: viewModel.selectedTag != nil
                                    ? "#\(viewModel.selectedTag!)"
                                    : viewModel.searchText,
                                subtitle: "\(viewModel.filteredPosts.count) results"
                            )
                        }
 
                        // ── Grid ──────────────────────
                        if viewModel.isLoading {
                            loadingView
                        } else if viewModel.filteredPosts.isEmpty {
                            emptyView
                        } else {
                            postsGrid
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.loadPosts() }
        .onChange(of: viewModel.searchText) { _, q in
            viewModel.search(query: q)
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Search Bar
    // ─────────────────────────────────
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(FMColors.cream.opacity(0.35))
 
            ZStack(alignment: .leading) {
                if viewModel.searchText.isEmpty {
                    Text("Search food, cuisine, tags...")
                        .font(.system(size: 15))
                        .foregroundColor(FMColors.cream.opacity(0.25))
                }
                TextField("", text: $viewModel.searchText)
                    .font(.system(size: 15))
                    .foregroundColor(FMColors.cream)
                    .focused($focused)
            }
 
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    focused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(FMColors.cream.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(hex: "1C1D17"))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
 
    // ─────────────────────────────────
    // MARK: — Trending Tags
    // ─────────────────────────────────
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRENDING")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(FMColors.cream.opacity(0.3))
                .tracking(1.5)
                .padding(.horizontal, 16)
 
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.trendingTags) { tag in
                        Button {
                            viewModel.filterByTag(tag.tag)
                        } label: {
                            HStack(spacing: 4) {
                                Text(tag.tag)
                                    .font(.system(size: 12, weight: .medium))
                                Text("·")
                                    .opacity(0.4)
                                Text("\(tag.count)")
                                    .font(.system(size: 11))
                                    .opacity(0.6)
                            }
                            .foregroundColor(
                                viewModel.selectedTag == tag.tag
                                    ? FMColors.background
                                    : FMColors.cream
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                viewModel.selectedTag == tag.tag
                                    ? FMColors.green
                                    : Color(hex: "1C1D17")
                            )
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
 
    // ─────────────────────────────────
    // MARK: — Section Header
    // ─────────────────────────────────
    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .italic()
                .foregroundColor(FMColors.cream)
            Spacer()
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(FMColors.cream.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
 
    // ─────────────────────────────────
    // MARK: — Nutrition Card
    // ─────────────────────────────────
    private func nutritionCard(_ s: SearchViewModel.NutritionSummary) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(s.dishName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(FMColors.cream)
                    Text("community average · \(s.postCount) scans")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.35))
                }
                Spacer()
                (
                    Text("~\(s.avgCal)")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(FMColors.orange)
                    + Text(" kcal")
                        .font(.system(size: 12))
                        .foregroundColor(FMColors.orange.opacity(0.7))
                )
            }
 
            HStack(spacing: 0) {
                macroCell(
                    label: "Protein",
                    value: "\(Int(s.avgPro))g",
                    color: FMColors.green
                )
                Rectangle()
                    .fill(FMColors.cream.opacity(0.08))
                    .frame(width: 1, height: 32)
                macroCell(
                    label: "Carbs",
                    value: "\(Int(s.avgCarbs))g",
                    color: FMColors.yellow
                )
                Rectangle()
                    .fill(FMColors.cream.opacity(0.08))
                    .frame(width: 1, height: 32)
                macroCell(
                    label: "Fat",
                    value: "\(Int(s.avgFat))g",
                    color: FMColors.orange
                )
            }
            .padding(.vertical, 10)
            .background(Color(hex: "141510"))
            .cornerRadius(10)
        }
        .padding(14)
        .background(Color(hex: "1C1D17"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FMColors.green.opacity(0.15), lineWidth: 1)
        )
    }
 
    private func macroCell(
        label: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(FMColors.cream.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }
 
    // ─────────────────────────────────
    // MARK: — Posts Grid
    // ─────────────────────────────────
    private var postsGrid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(viewModel.filteredPosts) { post in
                SearchPostCell(post: post)
            }
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Loading
    // ─────────────────────────────────
    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(FMColors.green)
                .scaleEffect(1.2)
            Text("Loading scans...")
                .font(.system(size: 13))
                .foregroundColor(FMColors.cream.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
 
    // ─────────────────────────────────
    // MARK: — Empty
    // ─────────────────────────────────
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundColor(FMColors.cream.opacity(0.15))
            Text("No results")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FMColors.cream.opacity(0.4))
            Text("Try pizza, sushi, burger...")
                .font(.system(size: 12))
                .foregroundColor(FMColors.cream.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}
 
// ─────────────────────────────────────
// MARK: — Search Post Cell
// ─────────────────────────────────────
struct SearchPostCell: View {
 
    let post: FMPost
 
    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width
 
            ZStack(alignment: .bottomLeading) {
 
                // ── Photo or gradient ─────────
                if let imageURL = post.imageURL,
                   !imageURL.isEmpty,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            gradientBG
                        }
                    }
                    .frame(width: size, height: size)
                    .clipped()
                } else {
                    gradientBG
                        .frame(width: size, height: size)
                }
 
                // ── Gradient overlay ──────────
                LinearGradient(
                    colors: [.black.opacity(0.75), .clear],
                    startPoint: .bottom,
                    endPoint:   .top
                )
                .frame(height: size * 0.55)
 
                // ── Dish + calories ───────────
                VStack(alignment: .leading, spacing: 1) {
                    Text(post.dishName)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(FMColors.cream)
                        .lineLimit(1)
                    Text("\(post.nutrition.calories) kcal")
                        .font(.system(size: 8))
                        .foregroundColor(FMColors.orange)
                }
                .padding(5)
 
                // ── Emoji top right ───────────
                VStack {
                    HStack {
                        Spacer()
                        Text(post.foodEmoji)
                            .font(.system(size: 13))
                            .padding(4)
                    }
                    Spacer()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
 
    private var gradientBG: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: post.bgColor1),
                    Color(hex: post.bgColor2)
                ],
                startPoint: .topLeading,
                endPoint:   .bottomTrailing
            )
            Text(post.foodEmoji)
                .font(.system(size: 32))
        }
    }
}
