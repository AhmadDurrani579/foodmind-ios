//
//  AmbientGlowBackground.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

// Ambient background glows
struct AmbientGlowBackground: View {
    var body: some View {
        GeometryReader { geo in
            // Top-left green glow
            Circle()
                .fill(Color(hex: "263C16"))
                .frame(width: geo.size.width * 0.72)
                .blur(radius: 85)
                .offset(
                    x: -geo.size.width * 0.22,
                    y: -geo.size.height * 0.1
                )
                .opacity(0.45)
 
            // Bottom-right warm glow
            Circle()
                .fill(Color(hex: "2a1a0e"))
                .frame(width: geo.size.width * 0.6)
                .blur(radius: 70)
                .offset(
                    x: geo.size.width * 0.48,
                    y: geo.size.height * 0.62
                )
                .opacity(0.35)
        }
        .ignoresSafeArea()
    }
}
