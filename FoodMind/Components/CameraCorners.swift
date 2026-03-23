//
//  CameraCorners.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct CameraCorners: View {
 
    var confidence: Double = 0
 
    @State private var pulse    = false
    @State private var scanY:   CGFloat = 0
    @State private var scanning = false
 
    private var cornerColor: Color {
        if confidence >= 0.85 { return FMColors.green }
        if confidence >= 0.60 { return FMColors.yellow }
        if confidence >  0    { return FMColors.orange }
        return FMColors.cream.opacity(0.3)
    }
 
    var body: some View {
        ZStack {
 
            // ── Scan Line ─────────────────
            if confidence > 0 {
                ScanLineOverlay(
                    confidence: confidence,
                    color:      cornerColor
                )
                .frame(width: 240, height: 240)
                .clipped()
            }
 
            // ── Corner Accents ────────────
            CornerShape()
                .stroke(cornerColor, lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .offset(x: -110, y: -110)
 
            CornerShape()
                .stroke(cornerColor, lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(90))
                .offset(x: 110, y: -110)
 
            CornerShape()
                .stroke(cornerColor, lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(270))
                .offset(x: -110, y: 110)
 
            CornerShape()
                .stroke(cornerColor, lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(180))
                .offset(x: 110, y: 110)
        }
        .opacity(confidence > 0 ? (pulse ? 1.0 : 0.5) : 0.3)
        .animation(
            .easeInOut(duration: 0.9)
            .repeatForever(autoreverses: true),
            value: pulse
        )
        .onAppear { pulse = true }
    }
}
 
// ─────────────────────────────────────
// MARK: — Scan Line Overlay
// Sweeping line top → bottom
// ─────────────────────────────────────
struct ScanLineOverlay: View {
 
    let confidence: Double
    let color:      Color
 
    @State private var scanY: CGFloat = 0
 
    private var duration: Double {
        // Faster sweep at higher confidence
        if confidence >= 0.85 { return 2.5 }
        if confidence >= 0.60 { return 3.0 }
        return 3.5
    }
 
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
 
                // ── Trailing fade ─────────
                LinearGradient(
                    colors: [
                        color.opacity(0),
                        color.opacity(0.12)
                    ],
                    startPoint: .top,
                    endPoint:   .bottom
                )
                .frame(height: 60)
                .offset(y: scanY - 60)
 
                // ── Main scan line ────────
                Rectangle()
                    .fill(color.opacity(0.9))
                    .frame(height: 1.5)
                    .shadow(color: color.opacity(0.8), radius: 4, y: 0)
                    .offset(y: scanY)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                startScan(height: geo.size.height)
            }
            .onChange(of: confidence) {
                startScan(height: geo.size.height)
            }
        }
    }
 
    private func startScan(height: CGFloat) {
        scanY = 0
        withAnimation(
            .easeInOut(duration: duration)  // ← easeInOut not linear
            .repeatForever(autoreverses: true)  // ← bounce back up smoothly
        ) {
            scanY = height
        }
    }

}
