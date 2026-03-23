//
//  FeedView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI
 
// ─────────────────────────────────────
// MARK: — FeedView
// ─────────────────────────────────────
struct FeedView: View {
 
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                // ── Header ──────────────────
                FeedHeader()
 
                // ── Posts ───────────────────
                
                if viewModel.isSharing {
                    Spacer()
                    ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: FMColors.green))
                    .scaleEffect(1.4)
                    Spacer()

                }else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach($viewModel.posts) { $post in
                                FeedPostCard(post: $post)
                            }
                            
                            // Bottom padding for tab bar
                            Color.clear.frame(height: 90)
                        }
                    }.refreshable {
                        viewModel.loadFeed()        // ← pull to refresh
                    }
                    .onAppear {
                        if viewModel.posts.isEmpty {
                            viewModel.loadFeed()    // ← only on first load
                        }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: Notification.Name("NewPostShared")
                        )
                    ) { _ in
                        viewModel.loadFeed()        // ← refresh after share
                    }
                }
            }
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — Feed Header
// ─────────────────────────────────────
private struct FeedHeader: View {
    var body: some View {
        HStack {
            // App name
            Text("FoodMind")
                .font(.system(
                    size: 22,
                    weight: .semibold,
                    design: .serif
                ))
                .foregroundColor(FMColors.cream)
 
            Spacer()
 
            // Icons
            HStack(spacing: 10) {
                FMHeaderButton(icon: "bell")
                FMHeaderButton(icon: "bubble.left")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 58)
        .padding(.bottom, 14)
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
// MARK: — Feed Post Card
// ─────────────────────────────────────
struct FeedPostCard: View {
 
    @Binding var post: FMPost
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
 
            // ── Post Header ─────────────────
            PostHeader(post: post)
 
            // ── Food Photo ──────────────────
            FoodPhotoView(post: post)
 
            // ── Post Footer ─────────────────
            PostFooter(post: $post)
 
            // ── Divider ─────────────────────
            Rectangle()
                .fill(FMColors.border2)
                .frame(height: 0.5)
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — Post Header
// ─────────────────────────────────────
private struct PostHeader: View {
 
    let post: FMPost
 
    var body: some View {
        HStack(spacing: 10) {
 
            // Avatar
            ZStack {
                Circle()
                    .fill(FMColors.surface2)
                    .frame(width: 36, height: 36)
                Text(post.user.avatarEmoji)
                    .font(.system(size: 20))
            }
 
            // Username + time
            VStack(alignment: .leading, spacing: 2) {
                Text(post.user.username)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(FMColors.cream)
 
                HStack(spacing: 4) {
                    Text(post.timeAgo)
                    Text("·")
                    Image(systemName: "viewfinder")
                        .font(.system(size: 10))
                    Text("FoodMind scan")
                }
                .font(.system(size: 11))
                .foregroundColor(FMColors.cream)
            }
 
            Spacer()
 
            // More button
            Button {} label: {
                Text("···")
                    .font(.system(size: 18))
                    .foregroundColor(FMColors.cream)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
 
// ─────────────────────────────────────
// MARK: — Food Photo View
// ─────────────────────────────────────
private struct FoodPhotoView: View {

    let post: FMPost

    var body: some View {

        ZStack(alignment: .bottomLeading) {

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: post.bgColor1),
                            Color(hex: post.bgColor2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {

                    if let urlString = post.imageURL,
                       let url = URL(string: urlString) {

                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                    }
                }

            NutritionOverlay(post: post)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)   // ⭐ FIX
        .clipped()
    }
}
 
// ─────────────────────────────────────
// MARK: — Nutrition Overlay
// ─────────────────────────────────────
private struct NutritionOverlay: View {
 
    let post: FMPost
 
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
 
            // Dish name
            Text(post.dishName)
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .italic()
                .foregroundColor(FMColors.cream)
 
            // Nutrition pills row
            HStack(spacing: 8) {
                NutPill(
                    label: "🔥 \(post.nutrition.calories) kcal",
                    color: FMColors.orange
                )
                NutPill(
                    label: "💪 \(Int(post.nutrition.protein))g",
                    color: FMColors.green
                )
                NutPill(
                    label: "🍞 \(Int(post.nutrition.carbs))g",
                    color: FMColors.yellow
                )
            }
 
            // Confidence badge
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.green)
                Text("\(post.confidence)% confident · \(post.styleTag)")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream.opacity(0.5))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    FMColors.background.opacity(0.95),
                    FMColors.background.opacity(0.6),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
}
 
// ─────────────────────────────────────
// MARK: — Nutrition Pill
// ─────────────────────────────────────
private struct NutPill: View {
    let label: String
    var color: Color = FMColors.cream
 
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(FMColors.cream.opacity(0.75))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.4))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
    }
}
 
// ─────────────────────────────────────
// MARK: — Post Footer
// ─────────────────────────────────────
private struct PostFooter: View {
 
    @Binding var post: FMPost
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
 
            // Action buttons
            HStack(spacing: 16) {
 
                // Like
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        post.isLiked.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 17))
                            .foregroundColor(
                                post.isLiked
                                    ? .red
                                    : FMColors.cream.opacity(0.5)
                            )
                            .scaleEffect(post.isLiked ? 1.1 : 1.0)
 
                        Text("\(post.likes + (post.isLiked ? 1 : 0))")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                    }
                }
 
                // Comment
                Button {} label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                        Text("\(post.comments)")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                    }
                }
 
                // Share
                Button {} label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 16))
                        .foregroundColor(FMColors.cream.opacity(0.5))
                }
 
                Spacer()
 
                // Bookmark
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        post.isBookmarked.toggle()
                    }
                } label: {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(
                            post.isBookmarked
                                ? FMColors.green
                                : FMColors.cream.opacity(0.5)
                        )
                }
            }
 
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(post.tags, id: \.self) { tag in
                        FeedTag(label: tag)
                    }
                }
            }
 
            // Caption
            Group {
                Text(post.user.username)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(FMColors.cream) +
                Text(" \(post.caption)")
                    .font(.system(size: 13))
                    .foregroundColor(FMColors.cream.opacity(0.6))
            }
            .lineSpacing(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
 
// ─────────────────────────────────────
// MARK: — Feed Tag
// ─────────────────────────────────────
struct FeedTag: View {
    let label: String
 
    var body: some View {
        Text(label)
            .font(.system(size: 11))
            .foregroundColor(FMColors.cream.opacity(0.4))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(FMColors.surface2)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(FMColors.border2, lineWidth: 1)
            )
    }
}
 
// ─────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────
#Preview {
    FeedView()
}

