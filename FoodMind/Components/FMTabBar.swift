//
//  FMTabBar.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct FMTabBar: View {
 
    @Binding var selectedTab: FMTab
 
    var body: some View {
        HStack(spacing: 0) {
            FMTabItem(
                icon: "house.fill",
                label: "Home",
                tab: .feed,
                selectedTab: $selectedTab
            )
            FMTabItem(
                icon: "magnifyingglass",
                label: "Search",
                tab: .search,
                selectedTab: $selectedTab
            )
 
            // Camera tab — bigger centre button
            CameraTabItem(selectedTab: $selectedTab)
 
            FMTabItem(
                icon: "chart.bar.fill",
                label: "Stats",
                tab: .stats,
                selectedTab: $selectedTab
            )
            FMTabItem(
                icon: "person.fill",
                label: "Profile",
                tab: .profile,
                selectedTab: $selectedTab
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(Color(hex: "0A0B08").opacity(0.97))
                .ignoresSafeArea(edges: .bottom)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 0.5),
                    alignment: .top
                )
        )
    }
}
