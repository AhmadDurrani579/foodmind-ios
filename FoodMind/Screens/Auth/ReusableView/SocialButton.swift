//
//  SocialButton.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct SocialButton: View {
    let icon:   String
    let label:  String
    var action: () -> Void = {}
 
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                Text(label)
                    .font(.system(size: 14))
            }
            .foregroundColor(FMColors.cream.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(FMColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(FMColors.border, lineWidth: 1)
            )
        }
    }
}
