//
//  StatsView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI
 
// ─────────────────────────────────────
// MARK: — Stats Mock Data
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
 
extension FMDailyLog {
    static let mockWeek: [FMDailyLog] = [
        FMDailyLog(id: "1", day: "Monday",    shortDay: "Mon", calories: 1820, protein: 98,  carbs: 210, fat: 62, isToday: false),
        FMDailyLog(id: "2", day: "Tuesday",   shortDay: "Tue", calories: 2100, protein: 112, carbs: 245, fat: 74, isToday: false),
        FMDailyLog(id: "3", day: "Wednesday", shortDay: "Wed", calories: 1650, protein: 88,  carbs: 190, fat: 55, isToday: false),
        FMDailyLog(id: "4", day: "Thursday",  shortDay: "Thu", calories: 1940, protein: 104, carbs: 224, fat: 68, isToday: false),
        FMDailyLog(id: "5", day: "Friday",    shortDay: "Fri", calories: 2240, protein: 118, carbs: 260, fat: 78, isToday: false),
        FMDailyLog(id: "6", day: "Saturday",  shortDay: "Sat", calories: 1780, protein: 92,  carbs: 204, fat: 60, isToday: false),
        FMDailyLog(id: "7", day: "Sunday",    shortDay: "Sun", calories: 1920, protein: 102, carbs: 222, fat: 65, isToday: true)
    ]
 
    // Computed average
    static var weeklyAvgCalories: Int {
        mockWeek.map(\.calories).reduce(0, +) / mockWeek.count
    }
}
 
extension FMTopFood {
    static let mockTopFoods: [FMTopFood] = [
        FMTopFood(id: "1", emoji: "🥗", name: "Chicken Salad",      count: 8,  calories: 380, tag: "Healthy"),
        FMTopFood(id: "2", emoji: "🥣", name: "Overnight Oats",     count: 6,  calories: 340, tag: "Breakfast"),
        FMTopFood(id: "3", emoji: "🍝", name: "Spaghetti Bolognese", count: 4,  calories: 620, tag: "Italian"),
        FMTopFood(id: "4", emoji: "🍕", name: "Margherita Pizza",    count: 3,  calories: 890, tag: "Cheat day"),
        FMTopFood(id: "5", emoji: "🍳", name: "Eggs & Avocado",      count: 5,  calories: 420, tag: "Breakfast")
    ]
}

struct StatsView: View {
 
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var weeklyLogs = FMDailyLog.mockWeek
    @State private var topFoods   = FMTopFood.mockTopFoods
    @State private var selectedDay: FMDailyLog? = nil
 
    // Daily target
    private let calorieTarget = 2000
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                // ── Header ──────────────────
                StatsHeader(selectedPeriod: $selectedPeriod)
 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
 
                        // ── Today Summary ───────
                        TodaySummaryCard(
                            log: weeklyLogs.last!,
                            target: calorieTarget
                        )
 
                        // ── Weekly Chart ────────
                        WeeklyBarChart(
                            logs: weeklyLogs,
                            target: calorieTarget,
                            selectedDay: $selectedDay
                        )
 
                        // ── Macro Ring ──────────
                        MacroRingCard(
                            log: selectedDay ?? weeklyLogs.last!
                        )
 
                        // ── Streak + Scans ──────
                        StatsQuickRow()
 
                        // ── Top Foods ───────────
                        TopFoodsCard(foods: topFoods)
 
                        // ── Nutrient Breakdown ──
                        NutrientBreakdownCard(
                            logs: weeklyLogs
                        )
 
                        // Tab bar space
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
            }
        }
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
 
                // Export button
                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
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
 
            // Period selector
            HStack(spacing: 0) {
                ForEach(StatsPeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.system(
                                size: 13,
                                weight: selectedPeriod == period ? .semibold : .regular
                            ))
                            .foregroundColor(
                                selectedPeriod == period
                                    ? FMColors.background
                                    : FMColors.cream.opacity(0.4)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                selectedPeriod == period
                                    ? FMColors.green
                                    : Color.clear
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(FMColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(FMColors.border, lineWidth: 1)
            )
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
// MARK: — Today Summary Card
// ─────────────────────────────────────
private struct TodaySummaryCard: View {
 
    let log:    FMDailyLog
    let target: Int
 
    private var progress: CGFloat {
        min(CGFloat(log.calories) / CGFloat(target), 1.0)
    }
 
    private var remaining: Int {
        max(target - log.calories, 0)
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
 
            HStack {
                Text("Today")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("Target: \(target) kcal")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            // Big calorie number
            HStack(alignment: .bottom, spacing: 6) {
                Text("\(log.calories)")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(FMColors.cream)
                Text("kcal")
                    .font(.system(size: 14))
                    .foregroundColor(FMColors.cream25)
                    .padding(.bottom, 8)
 
                Spacer()
 
                // Remaining
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(remaining)")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(FMColors.green)
                    Text("remaining")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream25)
                }
            }
 
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(FMColors.surface2)
                        .frame(height: 8)
 
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            progress > 1.0
                                ? Color.red
                                : progress > 0.85
                                    ? FMColors.orange
                                    : FMColors.green
                        )
                        .frame(
                            width: geo.size.width * progress,
                            height: 8
                        )
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 8)
 
            // Macro row
            HStack(spacing: 0) {
                MacroStat(
                    label: "Protein",
                    value: "\(Int(log.protein))g",
                    color: FMColors.green
                )
                Divider()
                    .background(FMColors.border2)
                    .frame(height: 24)
                MacroStat(
                    label: "Carbs",
                    value: "\(Int(log.carbs))g",
                    color: FMColors.yellow
                )
                Divider()
                    .background(FMColors.border2)
                    .frame(height: 24)
                MacroStat(
                    label: "Fat",
                    value: "\(Int(log.fat))g",
                    color: FMColors.orange
                )
            }
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

private struct WeeklyBarChart: View {
 
    let logs:     [FMDailyLog]
    let target:   Int
    @Binding var selectedDay: FMDailyLog?
 
    private var maxCalories: Int {
        logs.map(\.calories).max() ?? 2500
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
 
            HStack {
                Text("Weekly Calories")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("avg \(FMDailyLog.weeklyAvgCalories)")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            // Chart
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
 
                    // Target line
                    let targetY = geo.size.height * (1 - CGFloat(target) / CGFloat(maxCalories + 200))
                    Rectangle()
                        .fill(FMColors.orange.opacity(0.3))
                        .frame(height: 1)
                        .offset(y: -geo.size.height + targetY + geo.size.height * 0.1)
 
                    // Bars
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(logs) { log in
                            VStack(spacing: 4) {
                                // Calorie label on selected
                                if selectedDay?.id == log.id {
                                    Text("\(log.calories)")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(FMColors.green)
                                }
 
                                // Bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        selectedDay?.id == log.id
                                            ? FMColors.green
                                            : log.isToday
                                                ? FMColors.green.opacity(0.7)
                                                : FMColors.surface2
                                    )
                                    .frame(
                                        height: geo.size.height * 0.85 *
                                        CGFloat(log.calories) /
                                        CGFloat(maxCalories + 200)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedDay = selectedDay?.id == log.id
                                                ? nil
                                                : log
                                        }
                                    }
 
                                // Day label
                                Text(log.shortDay)
                                    .font(.system(size: 9))
                                    .foregroundColor(
                                        log.isToday
                                            ? FMColors.green
                                            : FMColors.cream25
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 120)
 
            // Target label
            HStack(spacing: 4) {
                Rectangle()
                    .fill(FMColors.orange.opacity(0.4))
                    .frame(width: 16, height: 1)
                Text("Daily target \(target) kcal")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.orange.opacity(0.6))
            }
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
 
// ─────────────────────────────────────
// MARK: — Macro Ring Card
// ─────────────────────────────────────
private struct MacroRingCard: View {
 
    let log: FMDailyLog
 
    private var totalMacros: Double {
        log.protein + log.carbs + log.fat
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
 
            HStack {
                Text("Macro Split")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text(log.isToday ? "Today" : log.day)
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            HStack(spacing: 20) {
 
                // Ring chart
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(FMColors.surface2, lineWidth: 14)
                        .frame(width: 100, height: 100)
 
                    // Fat arc
                    Circle()
                        .trim(
                            from: 0,
                            to: CGFloat(log.fat / totalMacros)
                        )
                        .stroke(FMColors.orange, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
 
                    // Carbs arc
                    Circle()
                        .trim(
                            from: CGFloat(log.fat / totalMacros),
                            to: CGFloat((log.fat + log.carbs) / totalMacros)
                        )
                        .stroke(FMColors.yellow, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
 
                    // Protein arc
                    Circle()
                        .trim(
                            from: CGFloat((log.fat + log.carbs) / totalMacros),
                            to: 1.0
                        )
                        .stroke(FMColors.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
 
                    // Centre label
                    VStack(spacing: 1) {
                        Text("\(log.calories)")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(FMColors.cream)
                        Text("kcal")
                            .font(.system(size: 9))
                            .foregroundColor(FMColors.cream25)
                    }
                }
 
                // Legend
                VStack(alignment: .leading, spacing: 10) {
                    MacroLegendRow(
                        color: FMColors.green,
                        label: "Protein",
                        value: "\(Int(log.protein))g",
                        percent: Int(log.protein / totalMacros * 100)
                    )
                    MacroLegendRow(
                        color: FMColors.yellow,
                        label: "Carbs",
                        value: "\(Int(log.carbs))g",
                        percent: Int(log.carbs / totalMacros * 100)
                    )
                    MacroLegendRow(
                        color: FMColors.orange,
                        label: "Fat",
                        value: "\(Int(log.fat))g",
                        percent: Int(log.fat / totalMacros * 100)
                    )
                }
 
                Spacer()
            }
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

// ─────────────────────────────────────
// MARK: — Quick Stats Row
// ─────────────────────────────────────
private struct StatsQuickRow: View {
    var body: some View {
        HStack(spacing: 10) {
 
            QuickStatCard(
                icon: "flame.fill",
                iconColor: FMColors.orange,
                value: "12",
                label: "Day Streak",
                suffix: "🔥"
            )
 
            QuickStatCard(
                icon: "viewfinder",
                iconColor: FMColors.green,
                value: "47",
                label: "Total Scans",
                suffix: ""
            )
 
            QuickStatCard(
                icon: "star.fill",
                iconColor: FMColors.yellow,
                value: "94%",
                label: "Avg Accuracy",
                suffix: ""
            )
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
                Text("Most Scanned")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("This week")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            ForEach(Array(foods.enumerated()), id: \.element.id) { index, food in
                HStack(spacing: 12) {
 
                    // Rank
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(
                            index == 0 ? FMColors.yellow :
                            index == 1 ? FMColors.cream50 :
                            FMColors.cream25
                        )
                        .frame(width: 16)
 
                    // Emoji
                    Text(food.emoji)
                        .font(.system(size: 22))
 
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(FMColors.cream)
                        Text("\(food.count)x scanned · \(food.calories) kcal avg")
                            .font(.system(size: 11))
                            .foregroundColor(FMColors.cream25)
                    }
 
                    Spacer()
 
                    // Tag
                    Text(food.tag)
                        .font(.system(size: 10))
                        .foregroundColor(FMColors.green.opacity(0.7))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(FMColors.green.opacity(0.08))
                        .cornerRadius(6)
                }
                .padding(.vertical, 4)
 
                if index < foods.count - 1 {
                    Rectangle()
                        .fill(FMColors.border2)
                        .frame(height: 0.5)
                }
            }
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
 
// ─────────────────────────────────────
// MARK: — Nutrient Breakdown Card
// ─────────────────────────────────────
private struct NutrientBreakdownCard: View {
 
    let logs: [FMDailyLog]
 
    private var avgProtein: Int {
        Int(logs.map(\.protein).reduce(0, +) / Double(logs.count))
    }
    private var avgCarbs: Int {
        Int(logs.map(\.carbs).reduce(0, +) / Double(logs.count))
    }
    private var avgFat: Int {
        Int(logs.map(\.fat).reduce(0, +) / Double(logs.count))
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
 
            HStack {
                Text("Weekly Averages")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("per day")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            // Protein
            NutrientRow(
                label: "Protein",
                value: avgProtein,
                unit: "g",
                target: 150,
                color: FMColors.green,
                tip: "Good — aim for 150g"
            )
 
            // Carbs
            NutrientRow(
                label: "Carbohydrates",
                value: avgCarbs,
                unit: "g",
                target: 250,
                color: FMColors.yellow,
                tip: "Slightly high"
            )
 
            // Fat
            NutrientRow(
                label: "Fat",
                value: avgFat,
                unit: "g",
                target: 65,
                color: FMColors.orange,
                tip: "On target"
            )
 
            // Calories
            NutrientRow(
                label: "Calories",
                value: FMDailyLog.weeklyAvgCalories,
                unit: "kcal",
                target: 2000,
                color: FMColors.cream50,
                tip: "Within range"
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
 
