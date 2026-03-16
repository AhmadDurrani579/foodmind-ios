//
//  BrandHeader.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct BrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
 
            LogoIconView(size: 52)
 
            Text("FoodMind")
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundColor(FMColors.cream)
                .padding(.top, 4)
 
            Text("Your food intelligence.\nKnow what you eat, instantly.")
                .font(.system(size: 14))
                .foregroundColor(FMColors.cream.opacity(0.45))
                .lineSpacing(5)
        }
    }
}
 
