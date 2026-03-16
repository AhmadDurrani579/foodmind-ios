//
//  ProfileStatCell.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct ProfileStatCell: View {
    let value: String
    let label: String
    var color: Color = FMColors.cream
 
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(FMColors.cream25)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(FMColors.surface)
    }
}
