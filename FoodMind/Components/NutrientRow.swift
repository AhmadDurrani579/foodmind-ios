//
//  NutrientRow.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct NutrientRow: View {
    let label:  String
    let value:  Int
    let unit:   String
    let target: Int
    let color:  Color
    let tip:    String
 
    private var progress: CGFloat {
        min(CGFloat(value) / CGFloat(target), 1.0)
    }
 
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream50)
 
                Spacer()
 
                Text("\(value)\(unit)")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundColor(color)
 
                Text("/ \(target)\(unit)")
                    .font(.system(size: 11))
                    .foregroundColor(FMColors.cream25)
            }
 
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(FMColors.surface2)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.6).delay(0.1), value: progress)
                }
            }
            .frame(height: 5)
 
            HStack {
                Text(tip)
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10))
                    .foregroundColor(FMColors.cream25)
            }
        }
    }
}
