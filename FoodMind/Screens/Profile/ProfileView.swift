//
//  ProfileView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI


struct FMScanHistoryItem: Identifiable {
    let id:       String
    let emoji:    String
    let name:     String
    let time:     String
    let calories: Int
    let protein:  Int
    let carbs:    Int
    let fat:      Int
    let styleTag: String
}
 
extension FMScanHistoryItem {
    static let mockData: [FMScanHistoryItem] = [
        FMScanHistoryItem(
            id: "s1",
            emoji: "🥗",
            name: "Grilled Chicken Salad",
            time: "Today · 1:24 PM",
            calories: 380,
            protein: 42,
            carbs: 12,
            fat: 9,
            styleTag: "Healthy"
        ),
        FMScanHistoryItem(
            id: "s2",
            emoji: "🥣",
            name: "Overnight Oats",
            time: "Today · 8:30 AM",
            calories: 340,
            protein: 14,
            carbs: 52,
            fat: 8,
            styleTag: "Breakfast"
        ),
        FMScanHistoryItem(
            id: "s3",
            emoji: "🍝",
            name: "Spaghetti Bolognese",
            time: "Yesterday · 7:12 PM",
            calories: 620,
            protein: 28,
            carbs: 74,
            fat: 18,
            styleTag: "Italian"
        ),
        FMScanHistoryItem(
            id: "s4",
            emoji: "🍳",
            name: "Eggs & Avocado Toast",
            time: "Yesterday · 9:00 AM",
            calories: 420,
            protein: 18,
            carbs: 38,
            fat: 22,
            styleTag: "Breakfast"
        ),
        FMScanHistoryItem(
            id: "s5",
            emoji: "🍕",
            name: "Margherita Pizza",
            time: "2 days ago · 8:30 PM",
            calories: 890,
            protein: 31,
            carbs: 98,
            fat: 34,
            styleTag: "Italian"
        )
    ]
}


struct ProfileView: View {
    
    // Mock data — replace with real user later
    @State private var scanHistory = FMScanHistoryItem.mockData
    @State private var showSettings = false
    
    // Weekly calorie bars (Mon–Sun)
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
                    
                    // ── Header ──────────────
                    ProfileHeader(showSettings: $showSettings)
                    
                    VStack(spacing: 12) {
                        
                        // ── Profile Card ────
                        ProfileCard()
                        
                        // ── Stats Strip ─────
                        ProfileStatsStrip()
                        
                        // ── Food Identity ───
                        FoodIdentityCard()
                        
                        // ── Weekly Chart ────
                        WeeklyCalorieChart(bars: weeklyBars)
                        
                        // ── Macros ──────────
                        MacroBreakdownCard()
                        
                        // ── Scan History ────
                        ScanHistorySection(items: scanHistory)
                        
                        // Tab bar space
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
            }
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
 
                Text("A")
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(FMColors.cream)
            }
 
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Ahmad Khan")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(FMColors.cream)
 
                Text("@ahmad · London 🇬🇧")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream25)
 
                Text("\"Eating well, tracking everything\"")
                    .font(.system(size: 12))
                    .italic()
                    .foregroundColor(FMColors.cream.opacity(0.4))
                    .padding(.top, 2)
            }
 
            Spacer()
 
            // Edit button
            Button("Edit") {}
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
}
 

private struct ProfileStatsStrip: View {
    var body: some View {
        HStack(spacing: 1) {
            ProfileStatCell(
                value: "47",
                label: "Scans",
                color: FMColors.green
            )
            ProfileStatCell(
                value: "1,840",
                label: "Avg kcal",
                color: FMColors.cream
            )
            ProfileStatCell(
                value: "234",
                label: "Followers",
                color: FMColors.cream
            )
            ProfileStatCell(
                value: "12 🔥",
                label: "Streak",
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
    let items: [FMScanHistoryItem]
 
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
 
            ForEach(items) { item in
                ScanHistoryRow(item: item)
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
 
