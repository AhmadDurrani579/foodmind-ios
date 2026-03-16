//
//  CircleIconButton.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct CircleIconButton: View {
    let icon: String
    var action: () -> Void = {}
 
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "F5EDD6").opacity(0.6))
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.08))
                .cornerRadius(14)
        }
    }
}
