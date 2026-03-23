//
//  ScanHistoryRow.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//
import SwiftUI

struct ScanHistoryRow: View {
    let item: Scan
 
    var body: some View {
        HStack(spacing: 12) {
 
            // Food thumbnail
            RoundedRectangle(cornerRadius: 10)
                .fill(FMColors.surface2)
                .frame(width: 46, height: 46)
                .overlay(
                    Text(item.emoji)
                        .font(.system(size: 24))
                )
 
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Text(item.time)
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
 
                // Style tag
                Text(item.styleTag)
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.green.opacity(0.7))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(FMColors.green.opacity(0.08))
                    .cornerRadius(4)
            }
 
            Spacer()
 
            // Calories + macros
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(item.calories ?? 0)")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(FMColors.orange)
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
                Text("\(item.protein)p · \(item.carbs)c · \(item.fat)f")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
            }
        }
        .padding(12)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FMColors.border2, lineWidth: 1)
        )
    }
}
