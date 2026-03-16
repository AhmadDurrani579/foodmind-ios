//
//  FoodIdentityCard.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct FoodIdentityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
 
            HStack {
                Text("YOUR FOOD IDENTITY")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(FMColors.cream25)
                    .tracking(1.2)
 
                Spacer()
 
                // Dominant food tags
                HStack(spacing: 4) {
                    MiniTag(label: "💪 Protein")
                    MiniTag(label: "🥬 Clean")
                }
            }
 
            Text("\"A consistent eater — high protein, balanced macros. You prioritise fuel over indulgence.\"")
                .font(.system(size: 13, design: .serif))
                .italic()
                .foregroundColor(FMColors.cream.opacity(0.55))
                .lineSpacing(4)
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FMColors.green.opacity(0.15), lineWidth: 1)
        )
    }
}
