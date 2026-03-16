//
//  MacroBreakdownCard.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct MacroBreakdownCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
 
            HStack {
                Text("Weekly Macros")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Spacer()
                Text("7 day average")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream)
            }
 
            MacroRow(
                label: "Protein",
                value: "124g",
                percent: 0.72,
                color: FMColors.green
            )
            MacroRow(
                label: "Carbs",
                value: "218g",
                percent: 0.88,
                color: FMColors.yellow
            )
            MacroRow(
                label: "Fat",
                value: "68g",
                percent: 0.55,
                color: FMColors.orange
            )
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
