//
//  TrendingDishCard.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct TrendingDishCard: View {
 
    let dish: FMTrendingDish
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
 
            // Food emoji
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                FMColors.surface2,
                                FMColors.surface
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 80)
 
                Text(dish.emoji)
                    .font(.system(size: 36))
            }
 
            // Dish name
            Text(dish.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(FMColors.cream)
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)
 
            // Stats row
            HStack(spacing: 6) {
                // Tag
                Text(dish.tag)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: dish.tagColor))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: dish.tagColor).opacity(0.1))
                    .cornerRadius(4)
 
                Spacer()
 
                // Calories
                Text("\(dish.calories) kcal")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
            }
            .frame(width: 110)
 
            // Scan count
            HStack(spacing: 3) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 9))
                    .foregroundColor(FMColors.cream25)
                Text("\(dish.scans.formatted()) scans")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
            }
            .frame(width: 110, alignment: .leading)
        }
        .padding(10)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FMColors.border, lineWidth: 1)
        )
    }
}
