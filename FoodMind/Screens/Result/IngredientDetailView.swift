//
//  IngredientDetailView.swift
//  FoodMind
//
//  Created by Ahmad on 21/03/2026.
//


import SwiftUI

struct IngredientDetailView: View {
    let ingredient: ScanIngredient
    let totalCalories: Int
    @Environment(\.dismiss) var dismiss
    var onLog: (() -> Void)?

    var contributionPct: Double {
        totalCalories > 0
            ? Double(ingredient.calories) / Double(totalCalories)
            : 0
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Handle ──
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // ── Header ──
            HStack(spacing: 12) {
                Text(ingredient.emoji ?? "🍽️")
                    .font(.system(size: 28))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\(ingredient.grams)g")       // ← just grams, no serving
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(ingredient.calories) kcal")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.91, green: 0.35, blue: 0.24))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // ── Calorie contribution bar ──
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Calorie contribution")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(contributionPct * 100))% of meal")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.91, green: 0.35, blue: 0.24))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.91, green: 0.35, blue: 0.24))
                            .frame(width: geo.size.width * min(contributionPct, 1.0))
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // ── Position tag if available ──
            if let position = ingredient.position {
                HStack {
                    Text("Layer")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(position)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.75))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 7)

                Divider().overlay(Color.white.opacity(0.08))
                    .padding(.vertical, 4)
            }

            // ── Action buttons ──
            HStack(spacing: 8) {
                Button("Dismiss") { dismiss() }
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)

                Button {
                    onLog?()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Log to diary")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(red: 0.11, green: 0.62, blue: 0.46))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(white: 0.06))
        .cornerRadius(20)
    }
}

private struct MacroCard: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(white: 0.75))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}
