//
//  MiniTag.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct MiniTag: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 10))
            .foregroundColor(FMColors.green.opacity(0.8))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(FMColors.green.opacity(0.08))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(FMColors.green.opacity(0.15), lineWidth: 1)
            )
    }
}
