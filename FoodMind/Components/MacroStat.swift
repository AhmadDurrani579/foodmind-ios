//
//  MacroStat.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct MacroStat: View {
    let label: String
    let value: String
    let color: Color
 
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(FMColors.cream25)
        }
        .frame(maxWidth: .infinity)
    }
}
