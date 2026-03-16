//
//  FilterPill.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct FilterPill: View {
    let label:      String
    let isSelected: Bool
    let action:     () -> Void
 
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(
                    isSelected
                        ? FMColors.background
                        : FMColors.cream.opacity(0.5)
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected
                        ? FMColors.green
                        : FMColors.surface
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected
                                ? .clear
                                : FMColors.border,
                            lineWidth: 1
                        )
                )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
