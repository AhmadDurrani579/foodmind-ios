//
//  ScanResultView.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct ScanResultView: View {
 
    let result:    FoodClassificationResult
    let image:     UIImage
    var onDismiss: () -> Void = {}
 
    var body: some View {
        ZStack {
            FMColors.background.ignoresSafeArea()
 
            VStack(spacing: 20) {
 
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(FMColors.cream.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
 
                // Food image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
 
                // Result
                VStack(spacing: 8) {
                    Text(result.displayName)
                        .font(.system(
                            size: 28,
                            weight: .semibold,
                            design: .serif
                        ))
                        .italic()
                        .foregroundColor(FMColors.cream)
 
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: result.confidenceLevel.color))
                            .frame(width: 8, height: 8)
                        Text("\(result.confidencePercent)% confident · MobileNet")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                    }
                }
 
                // Placeholder nutrition
                VStack(spacing: 12) {
                    Text("NUTRITION BREAKDOWN")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(FMColors.cream.opacity(0.25))
                        .tracking(1.2)
 
                    HStack {
                        Text("Deep scan required")
                            .font(.system(size: 14))
                            .foregroundColor(FMColors.cream.opacity(0.4))
                        Spacer()
                        Text("Tap Deep Scan")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.green)
                    }
                    .padding(14)
                    .background(FMColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(FMColors.border, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
 
                // Close button
                Button("Done") {
                    onDismiss()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(FMColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(FMColors.green)
                .cornerRadius(12)
                .padding(.horizontal, 20)
 
                Spacer()
            }
        }
    }
}
