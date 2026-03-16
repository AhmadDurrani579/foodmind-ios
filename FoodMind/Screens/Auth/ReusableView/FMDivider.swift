//
//  FMDivider.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct FMDivider: View {
    let label: String
 
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(FMColors.border2)
                .frame(height: 1)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(FMColors.cream.opacity(0.22))
                .fixedSize()
            Rectangle()
                .fill(FMColors.border2)
                .frame(height: 1)
        }
    }
}
