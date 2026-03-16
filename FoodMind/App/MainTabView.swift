//
//  MainTabView.swift
//  FoodMind
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: FMTab = .feed

    // Hide tab bar when on camera
    var shouldShowTabBar: Bool {
        selectedTab != .camera
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── All screens ─────────────────
            ZStack {
                FeedView()
                    .opacity(selectedTab == .feed ? 1 : 0)
                    .allowsHitTesting(selectedTab == .feed)

                SearchView()
                    .opacity(selectedTab == .search ? 1 : 0)
                    .allowsHitTesting(selectedTab == .search)

                // Camera — full screen, no tab bar
                CameraView(selectedTab: $selectedTab)
                    .opacity(selectedTab == .camera ? 1 : 0)
                    .allowsHitTesting(selectedTab == .camera)

                StatsView()
                    .opacity(selectedTab == .stats ? 1 : 0)
                    .allowsHitTesting(selectedTab == .stats)

                ProfileView()
                    .opacity(selectedTab == .profile ? 1 : 0)
                    .allowsHitTesting(selectedTab == .profile)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Tab Bar (hidden on camera) ───
            if shouldShowTabBar {
                FMTabBar(selectedTab: $selectedTab)
                    .transition(
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                    )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
        .animation(
            .easeInOut(duration: 0.25),
            value: shouldShowTabBar
        )
    }
}
