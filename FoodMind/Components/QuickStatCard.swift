//
//  QuickStatCard.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct QuickStatCard: View {
    let icon:      String
    let iconColor: Color
    let value:     String
    let label:     String
    let suffix:    String
 
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
 
            Text(value + suffix)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(FMColors.cream)
 
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(FMColors.cream25)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FMColors.border, lineWidth: 1)
        )
    }
}
