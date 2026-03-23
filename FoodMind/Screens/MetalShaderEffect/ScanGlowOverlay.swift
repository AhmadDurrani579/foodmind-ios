//
//  ScanGlowOverlay.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import SwiftUI

struct ScanGlowOverlay: View {

    let width:      CGFloat
    let height:     CGFloat
    let confidence: Double

    @State private var pulse    = false
    @State private var scanY:   CGFloat = 0

    private var glowColor: Color {
        if confidence >= 0.85 { return FMColors.green }
        if confidence >= 0.60 { return FMColors.yellow }
        return FMColors.orange
    }

    private let cornerSize:  CGFloat = 22
    private let lineWidth:   CGFloat = 3

    var body: some View {
        ZStack {

            // ── Corner Accents ──────────
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let c = cornerSize
                let lw = lineWidth

                var path = Path()

                // Top-left
                path.move(to:    CGPoint(x: 0,   y: c))
                path.addLine(to: CGPoint(x: 0,   y: 0))
                path.addLine(to: CGPoint(x: c,   y: 0))

                // Top-right
                path.move(to:    CGPoint(x: w - c, y: 0))
                path.addLine(to: CGPoint(x: w,     y: 0))
                path.addLine(to: CGPoint(x: w,     y: c))

                // Bottom-left
                path.move(to:    CGPoint(x: 0,   y: h - c))
                path.addLine(to: CGPoint(x: 0,   y: h))
                path.addLine(to: CGPoint(x: c,   y: h))

                // Bottom-right
                path.move(to:    CGPoint(x: w - c, y: h))
                path.addLine(to: CGPoint(x: w,     y: h))
                path.addLine(to: CGPoint(x: w,     y: h - c))

                context.stroke(
                    path,
                    with: .color(glowColor.opacity(pulse ? 1.0 : 0.5)),
                    lineWidth: lw
                )
            }

            // ── Scan Line (high conf only) ──
            if confidence >= 0.85 {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                glowColor.opacity(0.8),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint:   .trailing
                        )
                    )
                    .frame(height: 2)
                    .offset(y: scanY - height / 2)
                    .clipped()
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: scanY
                    )
            }
        }
        .opacity(pulse ? 1.0 : 0.6)
        .animation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true),
            value: pulse
        )
        .onAppear {
            pulse = true
            scanY = height / 2  // ← start scan from top
        }
        .onChange(of: confidence) {
            // Restart scan line when confidence changes
            scanY = -(height / 2)
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                scanY = height / 2
            }
        }
    }
}
