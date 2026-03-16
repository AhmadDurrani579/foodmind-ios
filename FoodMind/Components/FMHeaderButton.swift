//
//  FMHeaderButton.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct FMHeaderButton: View {
    let icon: String
    var action: () -> Void = {}
 
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "F5EDD6").opacity(0.5))
                .frame(width: 32, height: 32)
                .background(Color(hex: "141510"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        }
    }
}
