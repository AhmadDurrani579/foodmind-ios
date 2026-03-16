//
//  LoadingDotsView.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI
struct LoadingDotsView: View {
 
    @State private var animating = false
 
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(FMColors.green)
                    .frame(width: 5, height: 5)
                    .opacity(animating ? 0.9 : 0.25)
                    .scaleEffect(animating ? 1.0 : 0.65)
                    .animation(
                        .easeInOut(duration: 0.55)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.16),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}
