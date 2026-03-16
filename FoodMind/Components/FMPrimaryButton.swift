//
//  FMPrimaryButton.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct FMPrimaryButton: View {
    let label:     String
    var isLoading: Bool     = false
    var action:    () -> Void
 
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: FMColors.background)
                        )
                        .scaleEffect(0.85)
                } else {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(FMColors.background)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                isLoading
                    ? FMColors.green.opacity(0.7)
                    : FMColors.green
            )
            .cornerRadius(10)
            .shadow(color: FMColors.green.opacity(0.25), radius: 12, y: 4)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}
