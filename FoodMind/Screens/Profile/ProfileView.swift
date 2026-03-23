//
//  ProfileView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI


struct ProfileView: View {

    @State private var showSettings = false
    @StateObject private var viewModel = ProfileViewModel()

    private let weeklyBars: [(String, CGFloat, Bool)] = [
        ("Mon", 0.70, false),
        ("Tue", 0.88, true),
        ("Wed", 0.60, false),
        ("Thu", 0.78, false),
        ("Fri", 0.95, true),
        ("Sat", 0.65, false),
        ("Sun", 0.72, false)
    ]

    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    ProfileHeader(showSettings: $showSettings)

                    VStack(spacing: 12) {

                        ProfileCard(user: viewModel.user)

                        ProfileStatsStrip(stats: viewModel.stats)

                        FoodIdentityCard()

                        WeeklyCalorieChart(bars: weeklyBars)

                        MacroBreakdownCard()

                        // Dynamic Scan History
                        ScanHistorySection(items: viewModel.recentScans)

                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
            }
        }
        .onAppear {
            viewModel.fetchProfile()
            viewModel.fetchRecentScans()
            viewModel.fetchStats()
        }
        .sheet(isPresented: $showSettings) {
            SettingsPlaceholder()
        }
    }
}

private struct ProfileHeader: View {
        @Binding var showSettings: Bool
     
        var body: some View {
            HStack {
                Text("Profile")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(FMColors.cream)
     
                Spacer()
     
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                        .foregroundColor(FMColors.cream.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(FMColors.surface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(FMColors.border, lineWidth: 1)
                        )
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

private struct ProfileCard: View {
    let user: User?
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with glow ring
            ZStack {
                Circle()
                    .stroke(FMColors.green.opacity(0.4), lineWidth: 2)
                    .frame(width: 66, height: 66)

                Circle()
                    .fill(FMColors.surface2)
                    .frame(width: 58, height: 58)

                if let avatar = user?.avatarURL,
                   let url = URL(string: avatar) {

                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())

                } else {

                    Text(initial)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(FMColors.cream)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {

                Text(fullName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(FMColors.cream)

                Text("@\(user?.username ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream25)

                Text("\"Eating well, tracking everything\"")
                    .font(.system(size: 12))
                    .italic()
                    .foregroundColor(FMColors.cream.opacity(0.4))
                    .padding(.top, 2)
            }

            Spacer()

            Button("Edit") {

            }
            .font(.system(size: 12))
            .foregroundColor(FMColors.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(FMColors.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FMColors.border, lineWidth: 1)
            )
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FMColors.border, lineWidth: 1)
        )
    }

    // MARK: Helpers

    private var fullName: String {
        "\(user?.firstName ?? "") \(user?.lastName ?? "")"
    }

    private var initial: String {
        user?.firstName.prefix(1).uppercased() ?? "?"
    }
}
 

private struct ProfileStatsStrip: View {
    let stats: ScanStats?

    var body: some View {
        HStack(spacing: 1) {
            ProfileStatCell(
                value: "\(stats?.totalScans ?? 0)",
                label: "Scans",
                color: FMColors.green
            )
            ProfileStatCell(
                value: "\(stats?.avgCalories ?? 0)",
                label: "Avg kcal",
                color: FMColors.cream
            )
            ProfileStatCell(
                value: "—",         // ← from social feature later
                label: "Followers",
                color: FMColors.cream
            )
            ProfileStatCell(
                value: "\(stats?.totalThisWeek ?? 0) 🔥",
                label: "This week",
                color: FMColors.orange
            )
        }
        .background(FMColors.border2)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FMColors.border2, lineWidth: 1)
        )
    }
}


private struct ScanHistorySection: View {
    let items: [Scan]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("RECENT SCANS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
                Spacer()
                Button("See all") {}
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.green)
            }

            if items.isEmpty {
                // ← Empty state
                VStack(spacing: 8) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 28))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                    Text("No scans yet")
                        .font(.system(size: 13))
                        .foregroundColor(FMColors.cream.opacity(0.3))
                    Text("Scan your first food to see history")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(FMColors.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FMColors.border2, lineWidth: 1)
                )
            } else {
                ForEach(items) { item in
                    ScanHistoryRow(item: item)
                }
            }
        }
    }
}


private struct SettingsPlaceholder: View {
    @Environment(\.dismiss) var dismiss
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(FMColors.cream)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundColor(FMColors.green)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
 
                Spacer()
                Text("Coming soon")
                    .foregroundColor(FMColors.cream25)
                Spacer()
            }
        }
    }
}
 
