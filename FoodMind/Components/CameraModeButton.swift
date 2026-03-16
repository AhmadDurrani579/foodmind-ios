//
//  CameraModeButton.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct CameraModeButton: View {
    let label:    String
    let isActive: Bool
    var action:   () -> Void = {}
 
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(
                    size: 13,
                    weight: isActive ? .semibold : .regular
                ))
                .foregroundColor(
                    isActive
                        ? FMColors.background
                        : FMColors.cream.opacity(0.4)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isActive
                        ? FMColors.green
                        : Color.clear
                )
                .cornerRadius(20)
        }
    }
}
