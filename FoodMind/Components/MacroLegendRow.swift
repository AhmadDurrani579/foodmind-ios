//
//  MacroLegendRow.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//


import SwiftUI

struct MacroLegendRow: View {
    let color:   Color
    let label:   String
    let value:   String
    let percent: Int
 
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
 
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(FMColors.cream50)
 
            Spacer()
 
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .serif))
                .foregroundColor(FMColors.cream)
 
            Text("\(percent)%")
                .font(.system(size: 10))
                .foregroundColor(FMColors.cream25)
                .frame(width: 28, alignment: .trailing)
        }
    }
}
