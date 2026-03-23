//
//  IngredientOverlay.swift
//  FoodMind
//
//  Created by Ahmad on 19/03/2026.
//

import SwiftUI

// ─────────────────────────────────────
// MARK: — Ingredient Overlay
// Floating labels over food photo
// ─────────────────────────────────────
// In IngredientOverlay.swift
// Replace entire file with:

struct ScanLineIngredientOverlay: View {

    let ingredients: [ScanIngredient]

    @State private var visibleCount = 0

    // Max 4 ingredients
    private var display: [ScanIngredient] {
        Array(ingredients.prefix(4))
    }

    var body: some View {
        HStack {
            Spacer()

            // ── Right side labels ─────────
            VStack(alignment: .trailing, spacing: 8) {
                Spacer()
                    .frame(minHeight: 30)
                ForEach(
                    Array(display.enumerated()),
                    id: \.element.id
                ) { index, ingredient in

                    if index < visibleCount {
                        ScanLineRow(
                            ingredient: ingredient,
                            index:      index
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing)
                                    .combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                    }
                }

                Spacer()
                    .frame(minHeight: 50)
            }
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        for i in 0..<display.count {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * 0.2 + 0.3
            ) {
                withAnimation(.spring(
                    response: 0.4,
                    dampingFraction: 0.7
                )) {
                    visibleCount = i + 1
                }
            }
        }
    }
}

// ── Single scan line row ──────────────
struct ScanLineRow: View {

    let ingredient: ScanIngredient
    let index:      Int

    private var accentColor: Color {
        switch index % 4 {
        case 0:  return FMColors.green
        case 1:  return FMColors.yellow
        case 2:  return FMColors.orange
        default: return Color(hex: "7BB8D8")
        }
    }

    var body: some View {
        HStack(spacing: 0) {

            // ── Connecting line ───────────
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            accentColor.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint:   .trailing
                    )
                )
                .frame(height: 1)
                .frame(maxWidth: 40)

            // ── Dot ───────────────────────
            Circle()
                .fill(accentColor)
                .frame(width: 5, height: 5)

            // ── Label card ────────────────
            HStack(spacing: 5) {
                Text(ingredient.emoji ?? "🍽️")
                    .font(.system(size: 12))

                VStack(alignment: .leading, spacing: 1) {
                    Text(ingredient.name)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(FMColors.cream)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)  // ← add
                        .frame(maxWidth: 90, alignment: .leading)       // ← add width
                    Text("\(ingredient.calories) kcal")
                        .font(.system(size: 8))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "0C0D09").opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                accentColor.opacity(0.4),
                                lineWidth: 0.5
                            )
                    )
            )
        }
        .padding(.trailing, 10)
    }
}
