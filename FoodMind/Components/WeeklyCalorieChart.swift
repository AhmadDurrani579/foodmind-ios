//
//  WeeklyCalorieChart.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct WeeklyCalorieChart: View {
 
    let bars: [(String, CGFloat, Bool)]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
 
            // Title row
            HStack {
                Text("Daily Calories")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("avg 1,840 kcal")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream)
            }
 
            // Bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(bars, id: \.0) { day, height, isHigh in
                    VStack(spacing: 6) {
                        // Value label on tall bars
                        if isHigh {
                            Text(day == "Tue" ? "1,980" : "2,100")
                                .font(.system(size: 8))
                                .foregroundColor(FMColors.green.opacity(0.7))
                        }
 
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                isHigh
                                    ? FMColors.green
                                    : FMColors.surface2
                            )
                            .frame(height: 52 * height)
 
                        Text(day)
                            .font(.system(size: 9))
                            .foregroundColor(FMColors.cream25)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
 
            // Target line label
            HStack {
                Rectangle()
                    .fill(FMColors.orange.opacity(0.4))
                    .frame(height: 1)
                    .overlay(
                        Text("target 2,000")
                            .font(.system(size: 9))
                            .foregroundColor(FMColors.orange.opacity(0.6))
                            .padding(.leading, 4),
                        alignment: .trailing
                    )
            }
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FMColors.border, lineWidth: 1)
        )
    }
}
