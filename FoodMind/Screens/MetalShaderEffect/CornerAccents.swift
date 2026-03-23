//
//  CornerAccents.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import SwiftUI

struct CornerAccents: View {
    let x:      CGFloat
    let y:      CGFloat
    let width:  CGFloat
    let height: CGFloat
    let color:  Color
    let pulse:  Bool

    private let size: CGFloat = 20
    private let thickness: CGFloat = 3

    var body: some View {
        ZStack(alignment: .topLeading) {

            // Top-left
            Path { p in
                p.move(to:    CGPoint(x: x,        y: y + size))
                p.addLine(to: CGPoint(x: x,        y: y))
                p.addLine(to: CGPoint(x: x + size, y: y))
            }
            .stroke(color, lineWidth: thickness)

            // Top-right
            Path { p in
                p.move(to:    CGPoint(x: x + width - size, y: y))
                p.addLine(to: CGPoint(x: x + width,        y: y))
                p.addLine(to: CGPoint(x: x + width,        y: y + size))
            }
            .stroke(color, lineWidth: thickness)

            // Bottom-left
            Path { p in
                p.move(to:    CGPoint(x: x,        y: y + height - size))
                p.addLine(to: CGPoint(x: x,        y: y + height))
                p.addLine(to: CGPoint(x: x + size, y: y + height))
            }
            .stroke(color, lineWidth: thickness)

            // Bottom-right
            Path { p in
                p.move(to:    CGPoint(x: x + width - size, y: y + height))
                p.addLine(to: CGPoint(x: x + width,        y: y + height))
                p.addLine(to: CGPoint(x: x + width,        y: y + height - size))
            }
            .stroke(color, lineWidth: thickness)
        }
        .opacity(pulse ? 1.0 : 0.4)
        .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
            value: pulse
        )
    }
}
