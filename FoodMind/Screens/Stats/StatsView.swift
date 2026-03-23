//
//  StatsView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//


import SwiftUI

// ─────────────────────────────────────
// MARK: — Data Models
// ─────────────────────────────────────
struct FMDailyLog: Identifiable {
    let id:       String
    let day:      String
    let shortDay: String
    let calories: Int
    let protein:  Double
    let carbs:    Double
    let fat:      Double
    let isToday:  Bool
}

struct FMTopFood: Identifiable {
    let id:       String
    let emoji:    String
    let name:     String
    let count:    Int
    let calories: Int
    let tag:      String
}

// ─────────────────────────────────────
// MARK: — StatsView
// ─────────────────────────────────────
struct StatsView: View {

    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var selectedDay:    FMDailyLog?  = nil

    private let calorieTarget = 2000

    // Convert real scans to FMDailyLog
    private var weeklyLogs: [FMDailyLog] {
        viewModel.recentScans.enumerated().map { index, scan in
            FMDailyLog(
                id:       scan.id,
                day:      scan.dish_name,
                shortDay: String(scan.dish_name.prefix(3)),
                calories: scan.calories ?? 0,
                protein:  scan.protein_g ?? 0,
                carbs:    scan.carbs_g ?? 0,
                fat:      scan.fat_g ?? 0,
                isToday:  index == 0
            )
        }
    }

    private var todayLog: FMDailyLog? { weeklyLogs.first }

    // Convert scans to top foods
    private var topFoods: [FMTopFood] {
        viewModel.recentScans.enumerated().map { index, scan in
            FMTopFood(
                id:       scan.id,
                emoji:    emojiFor(scan.cuisine),
                name:     scan.dish_name,
                count:    1,
                calories: scan.calories ?? 0,
                tag:      scan.cuisine ?? "Unknown"
            )
        }
    }

    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                StatsHeader(selectedPeriod: $selectedPeriod)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        if viewModel.isLoading {
                            // ── Loading ──────────────
                            loadingView

                        } else if weeklyLogs.isEmpty {
                            // ── Empty State ──────────
                            EmptyStatsView()

                        } else {
                            // ── Real Data ────────────
                            TodaySummaryCard(
                                log:    todayLog!,
                                target: calorieTarget
                            )

                            WeeklyBarChart(
                                logs:        weeklyLogs,
                                target:      calorieTarget,
                                selectedDay: $selectedDay
                            )

                            MacroRingCard(
                                log: selectedDay ?? todayLog!
                            )

                            StatsQuickRow(
                                totalScans:  viewModel.stats?.totalScans ?? 0,
                                thisWeek:    viewModel.stats?.totalThisWeek ?? 0,
                                avgCalories: Int(viewModel.stats?.avgCalories ?? 0)
                            )

                            if !topFoods.isEmpty {
                                TopFoodsCard(foods: topFoods)
                            }

                            NutrientBreakdownCard(
                                avgProtein:  Int(viewModel.stats?.avgProtein ?? 0),
                                avgCarbs:    Int(viewModel.stats?.avgCarbs ?? 0),
                                avgFat:      Int(viewModel.stats?.avgFat ?? 0),
                                avgCalories: Int(viewModel.stats?.avgCalories ?? 0)
                            )
                        }

                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
            }
        }
        .onAppear {
            viewModel.fetchStats()
            viewModel.fetchRecentScans()
        }
    }

    // ── Loading View ──────────────────
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: FMColors.green)
                )
                .scaleEffect(1.3)
            Text("Loading your stats...")
                .font(.system(size: 13))
                .foregroundColor(FMColors.cream.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }

    // ── Emoji Helper ──────────────────
    private func emojiFor(_ cuisine: String?) -> String {
        switch cuisine?.lowercased() {
        case "italian":   return "🍝"
        case "american":  return "🍔"
        case "japanese":  return "🍣"
        case "chinese":   return "🥡"
        case "indian":    return "🍛"
        case "mexican":   return "🌮"
        case "healthy":   return "🥗"
        case "breakfast": return "🍳"
        default:          return "🍽️"
        }
    }
}

// ─────────────────────────────────────
// MARK: — Empty Stats View
// ─────────────────────────────────────
private struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 20) {

            ZStack {
                Circle()
                    .fill(FMColors.surface)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(FMColors.border, lineWidth: 1)
                    )
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 38))
                    .foregroundColor(FMColors.green.opacity(0.4))
            }
            .padding(.top, 40)

            VStack(spacing: 8) {
                Text("No stats yet")
                    .font(.system(
                        size: 20,
                        weight: .semibold,
                        design: .serif
                    ))
                    .foregroundColor(FMColors.cream.opacity(0.5))

                Text("Scan your first food to see\nyour nutrition stats here")
                    .font(.system(size: 13))
                    .foregroundColor(FMColors.cream.opacity(0.25))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Hint
            HStack(spacing: 8) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.green.opacity(0.5))
                Text("Tap the camera tab to scan food")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream.opacity(0.25))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(FMColors.surface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(FMColors.border, lineWidth: 1)
            )
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

// ─────────────────────────────────────
// MARK: — Period Enum
// ─────────────────────────────────────
enum StatsPeriod: String, CaseIterable {
    case week  = "Week"
    case month = "Month"
    case year  = "Year"
}

// ─────────────────────────────────────
// MARK: — Stats Header
// ─────────────────────────────────────
private struct StatsHeader: View {

    @Binding var selectedPeriod: StatsPeriod

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Stats")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
                        .foregroundColor(FMColors.cream.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(FMColors.surface)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FMColors.border, lineWidth: 1))
                }
            }

            HStack(spacing: 0) {
                ForEach(StatsPeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedPeriod = period }
                    } label: {
                        Text(period.rawValue)
                            .font(.system(size: 13, weight: selectedPeriod == period ? .semibold : .regular))
                            .foregroundColor(selectedPeriod == period ? FMColors.background : FMColors.cream.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? FMColors.green : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(FMColors.surface)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(FMColors.border, lineWidth: 1))
        }
        .padding(.horizontal, 18)
        .padding(.top, 58)
        .padding(.bottom, 14)
        .background(FMColors.background)
        .overlay(Rectangle().fill(FMColors.border2).frame(height: 0.5), alignment: .bottom)
    }
}

// ─────────────────────────────────────
// MARK: — Today Summary Card
// ─────────────────────────────────────
private struct TodaySummaryCard: View {

    let log:    FMDailyLog
    let target: Int

    private var progress: CGFloat { min(CGFloat(log.calories) / CGFloat(target), 1.0) }
    private var remaining: Int { max(target - log.calories, 0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Latest Scan")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("Target: \(target) kcal")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }

            HStack(alignment: .bottom, spacing: 6) {
                Text("\(log.calories)")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(FMColors.cream)
                Text("kcal")
                    .font(.system(size: 14))
                    .foregroundColor(FMColors.cream25)
                    .padding(.bottom, 8)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(remaining)")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(FMColors.green)
                    Text("remaining")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream25)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(FMColors.surface2).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progress > 1.0 ? Color.red : progress > 0.85 ? FMColors.orange : FMColors.green)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 8)

            HStack(spacing: 0) {
                MacroStat(label: "Protein", value: "\(Int(log.protein))g", color: FMColors.green)
                Divider().background(FMColors.border2).frame(height: 24)
                MacroStat(label: "Carbs",   value: "\(Int(log.carbs))g",   color: FMColors.yellow)
                Divider().background(FMColors.border2).frame(height: 24)
                MacroStat(label: "Fat",     value: "\(Int(log.fat))g",     color: FMColors.orange)
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}

// ─────────────────────────────────────
// MARK: — Weekly Bar Chart
// ─────────────────────────────────────
private struct WeeklyBarChart: View {

    let logs:     [FMDailyLog]
    let target:   Int
    @Binding var selectedDay: FMDailyLog?

    private var maxCalories: Int { logs.map(\.calories).max() ?? 2500 }
    private var avgCalories: Int {
        guard !logs.isEmpty else { return 0 }
        return logs.map(\.calories).reduce(0, +) / logs.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scan History")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("avg \(avgCalories) kcal")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }

            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    let targetY = geo.size.height * (1 - CGFloat(target) / CGFloat(maxCalories + 200))
                    Rectangle()
                        .fill(FMColors.orange.opacity(0.3))
                        .frame(height: 1)
                        .offset(y: -geo.size.height + targetY + geo.size.height * 0.1)

                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(logs) { log in
                            VStack(spacing: 4) {
                                if selectedDay?.id == log.id {
                                    Text("\(log.calories)")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(FMColors.green)
                                }
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selectedDay?.id == log.id ? FMColors.green : log.isToday ? FMColors.green.opacity(0.7) : FMColors.surface2)
                                    .frame(height: geo.size.height * 0.85 * CGFloat(log.calories) / CGFloat(maxCalories + 200))
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedDay = selectedDay?.id == log.id ? nil : log
                                        }
                                    }
                                Text(log.shortDay)
                                    .font(.system(size: 9))
                                    .foregroundColor(log.isToday ? FMColors.green : FMColors.cream25)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 120)

            HStack(spacing: 4) {
                Rectangle().fill(FMColors.orange.opacity(0.4)).frame(width: 16, height: 1)
                Text("Daily target \(target) kcal").font(.system(size: 10)).foregroundColor(FMColors.orange.opacity(0.6))
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}

// ─────────────────────────────────────
// MARK: — Macro Ring Card
// ─────────────────────────────────────
private struct MacroRingCard: View {

    let log: FMDailyLog
    private var totalMacros: Double { max(log.protein + log.carbs + log.fat, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Macro Split")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text(log.isToday ? "Latest" : log.day)
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }

            HStack(spacing: 20) {
                ZStack {
                    Circle().stroke(FMColors.surface2, lineWidth: 14).frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: CGFloat(log.fat / totalMacros))
                        .stroke(FMColors.orange, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100).rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: CGFloat(log.fat / totalMacros), to: CGFloat((log.fat + log.carbs) / totalMacros))
                        .stroke(FMColors.yellow, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100).rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: CGFloat((log.fat + log.carbs) / totalMacros), to: 1.0)
                        .stroke(FMColors.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100).rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("\(log.calories)").font(.system(size: 15, weight: .bold, design: .serif)).foregroundColor(FMColors.cream)
                        Text("kcal").font(.system(size: 9)).foregroundColor(FMColors.cream25)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    MacroLegendRow(color: FMColors.green,  label: "Protein", value: "\(Int(log.protein))g", percent: Int(log.protein / totalMacros * 100))
                    MacroLegendRow(color: FMColors.yellow, label: "Carbs",   value: "\(Int(log.carbs))g",   percent: Int(log.carbs / totalMacros * 100))
                    MacroLegendRow(color: FMColors.orange, label: "Fat",     value: "\(Int(log.fat))g",     percent: Int(log.fat / totalMacros * 100))
                }
                Spacer()
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}

// ─────────────────────────────────────
// MARK: — Quick Stats Row
// ─────────────────────────────────────
private struct StatsQuickRow: View {
    let totalScans:  Int
    let thisWeek:    Int
    let avgCalories: Int

    var body: some View {
        HStack(spacing: 10) {
            QuickStatCard(icon: "flame.fill",  iconColor: FMColors.orange, value: "\(thisWeek)",    label: "This Week",    suffix: "🔥")
            QuickStatCard(icon: "viewfinder",  iconColor: FMColors.green,  value: "\(totalScans)",  label: "Total Scans",  suffix: "")
            QuickStatCard(icon: "flame",       iconColor: FMColors.yellow, value: "\(avgCalories)", label: "Avg Calories", suffix: "")
        }
    }
}

// ─────────────────────────────────────
// MARK: — Top Foods Card
// ─────────────────────────────────────
private struct TopFoodsCard: View {
    let foods: [FMTopFood]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Dishes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("Last \(foods.count) scans")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }

            ForEach(Array(foods.prefix(5).enumerated()), id: \.element.id) { index, food in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(index == 0 ? FMColors.yellow : index == 1 ? FMColors.cream50 : FMColors.cream25)
                        .frame(width: 16)
                    Text(food.emoji).font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name).font(.system(size: 13, weight: .medium)).foregroundColor(FMColors.cream)
                        Text("\(food.calories) kcal").font(.system(size: 11)).foregroundColor(FMColors.cream25)
                    }
                    Spacer()
                    Text(food.tag)
                        .font(.system(size: 10))
                        .foregroundColor(FMColors.green.opacity(0.7))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(FMColors.green.opacity(0.08)).cornerRadius(6)
                }
                .padding(.vertical, 4)
                if index < min(foods.count, 5) - 1 {
                    Rectangle().fill(FMColors.border2).frame(height: 0.5)
                }
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}

// ─────────────────────────────────────
// MARK: — Nutrient Breakdown
// ─────────────────────────────────────
private struct NutrientBreakdownCard: View {
    let avgProtein:  Int
    let avgCarbs:    Int
    let avgFat:      Int
    let avgCalories: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Weekly Averages")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("per scan")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
            NutrientRow(label: "Protein",       value: avgProtein,  unit: "g",    target: 150,  color: FMColors.green,   tip: avgProtein >= 100 ? "Good — aim for 150g" : "Increase protein")
            NutrientRow(label: "Carbohydrates", value: avgCarbs,    unit: "g",    target: 250,  color: FMColors.yellow,  tip: avgCarbs > 200 ? "Slightly high" : "On target")
            NutrientRow(label: "Fat",           value: avgFat,      unit: "g",    target: 65,   color: FMColors.orange,  tip: avgFat > 65 ? "Slightly high" : "On target")
            NutrientRow(label: "Calories",      value: avgCalories, unit: "kcal", target: 2000, color: FMColors.cream50, tip: avgCalories > 2000 ? "Above target" : "Within range")
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
    }
}
