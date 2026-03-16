//
//  LogoIconView.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct LogoIconView: View {
 
    let size: CGFloat
 
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size * 0.23)
                .fill(Color(hex: "12140C"))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.23)
                        .stroke(FMColors.green.opacity(0.2), lineWidth: 1)
                )
 
            // Inner radial glow
            RadialGradient(
                colors: [
                    FMColors.green.opacity(0.18),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: size * 0.75
            )
            .clipShape(
                RoundedRectangle(cornerRadius: size * 0.23)
            )
 
            // Logo mark drawn with Canvas
            Canvas { ctx, canvasSize in
                let cx = canvasSize.width  / 2
                let cy = canvasSize.height / 2
                let r  = size * 0.28
                let lw = max(1.2, size / 30)
 
                let green     = Color(hex: "8DB87A")
                let greenDim  = Color(hex: "8DB87A").opacity(0.3)
                let cream     = Color(hex: "F5EDD6").opacity(0.88)
 
                // Outer lens circle
                ctx.stroke(
                    Path { p in
                        p.addEllipse(in: CGRect(
                            x: cx - r, y: cy - r,
                            width: r * 2, height: r * 2
                        ))
                    },
                    with: .color(green),
                    lineWidth: lw
                )
 
                // Inner lens circle
                let ri = r * 0.62
                ctx.stroke(
                    Path { p in
                        p.addEllipse(in: CGRect(
                            x: cx - ri, y: cy - ri,
                            width: ri * 2, height: ri * 2
                        ))
                    },
                    with: .color(greenDim),
                    lineWidth: max(0.8, lw - 0.4)
                )
 
                // Crosshair lines
                let gap = r * 0.22
                let ext = r * 0.32
 
                // Top
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: cx, y: cy - r - ext))
                    p.addLine(to: CGPoint(x: cx, y: cy - r - gap))
                }, with: .color(green), lineWidth: lw)
 
                // Bottom
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: cx, y: cy + r + gap))
                    p.addLine(to: CGPoint(x: cx, y: cy + r + ext))
                }, with: .color(green), lineWidth: lw)
 
                // Left
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: cx - r - ext, y: cy))
                    p.addLine(to: CGPoint(x: cx - r - gap, y: cy))
                }, with: .color(green), lineWidth: lw)
 
                // Right
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: cx + r + gap, y: cy))
                    p.addLine(to: CGPoint(x: cx + r + ext, y: cy))
                }, with: .color(green), lineWidth: lw)
 
                // Fork — left of centre
                let fw  = max(0.8, lw - 0.3)
                let fx  = cx - size * 0.10
                let fT  = cy - size * 0.18
                let fB  = cy + size * 0.18
                let tw  = size * 0.038
                let th  = size * 0.08
 
                // Handle
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: fx, y: fT + th + size * 0.03))
                    p.addLine(to: CGPoint(x: fx, y: fB))
                }, with: .color(cream), lineWidth: fw)
 
                // Tines
                for tx in [fx - tw, fx + tw] {
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: tx, y: fT))
                        p.addLine(to: CGPoint(x: tx, y: fT + th))
                    }, with: .color(cream), lineWidth: max(0.6, fw - 0.2))
                }
 
                // Tine curve
                ctx.stroke(Path { p in
                    p.addArc(
                        center: CGPoint(x: fx, y: fT + th + size * 0.028),
                        radius: tw + size * 0.006,
                        startAngle: .degrees(0),
                        endAngle: .degrees(180),
                        clockwise: false
                    )
                }, with: .color(cream), lineWidth: max(0.6, fw - 0.2))
 
                // Spoon — right of centre
                let sx = cx + size * 0.10
                let sT = cy - size * 0.18
                let sB = cy + size * 0.18
                let sr = size * 0.05
 
                // Bowl
                ctx.stroke(Path { p in
                    p.addEllipse(in: CGRect(
                        x: sx - sr, y: sT,
                        width: sr * 2, height: sr * 2.2
                    ))
                }, with: .color(cream), lineWidth: max(0.6, fw - 0.2))
 
                // Handle
                ctx.stroke(Path { p in
                    p.move(to: CGPoint(x: sx, y: sT + sr * 2.0))
                    p.addLine(to: CGPoint(x: sx, y: sB))
                }, with: .color(cream), lineWidth: fw)
 
                // AI spark dot — top right
                let dotX = cx + r * 0.62
                let dotY = cy - r * 0.70
                let dotR = size * 0.075
 
                ctx.fill(Path { p in
                    p.addEllipse(in: CGRect(
                        x: dotX - dotR, y: dotY - dotR,
                        width: dotR * 2, height: dotR * 2
                    ))
                }, with: .color(green))
 
                let innerR = dotR * 0.5
                ctx.fill(Path { p in
                    p.addEllipse(in: CGRect(
                        x: dotX - innerR, y: dotY - innerR,
                        width: innerR * 2, height: innerR * 2
                    ))
                }, with: .color(Color(hex: "F5EDD6")))
 
                // Neural dots — bottom left
                let ndots: [(CGFloat, CGFloat)] = [
                    (cx - size * 0.26, cy + size * 0.32),
                    (cx - size * 0.14, cy + size * 0.36),
                    (cx - size * 0.02, cy + size * 0.32)
                ]
                for (i, (nx, ny)) in ndots.enumerated() {
                    ctx.fill(Path { p in
                        p.addEllipse(in: CGRect(x: nx - 2, y: ny - 2, width: 4, height: 4))
                    }, with: .color(green.opacity(i % 2 == 0 ? 0.5 : 0.35)))
                }
                for i in 0..<ndots.count - 1 {
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: ndots[i].0, y: ndots[i].1))
                        p.addLine(to: CGPoint(x: ndots[i+1].0, y: ndots[i+1].1))
                    }, with: .color(green.opacity(0.25)), lineWidth: 0.7)
                }
            }
            .frame(width: size * 0.62, height: size * 0.62)
        }
        .frame(width: size, height: size)
        .shadow(color: FMColors.green.opacity(0.15), radius: size * 0.35)
    }
}
