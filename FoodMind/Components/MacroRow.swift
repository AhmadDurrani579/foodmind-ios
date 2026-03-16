//
//  MacroRow.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct MacroRow: View {
    let label:   String
    let value:   String
    let percent: CGFloat
    let color:   Color
 
    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(FMColors.cream)
                .frame(width: 52, alignment: .leading)
 
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(FMColors.surface2)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.8))
                        .frame(width: geo.size.width * percent)
                        .animation(.spring(response: 0.6).delay(0.2), value: percent)
                }
            }
            .frame(height: 6)
 
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(FMColors.cream)
                .frame(width: 34, alignment: .trailing)
        }
    }
}
