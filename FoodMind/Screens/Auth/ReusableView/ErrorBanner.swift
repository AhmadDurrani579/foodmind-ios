//
//  ErrorBanner.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13))
                .foregroundColor(FMColors.orange)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(FMColors.cream.opacity(0.7))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(FMColors.orange.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(FMColors.orange.opacity(0.25), lineWidth: 1)
        )
    }
}
