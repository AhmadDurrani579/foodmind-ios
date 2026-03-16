//
//  TermsRow.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct TermsRow: View {

    @Binding var agreed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {

            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3)) {
                    agreed.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(agreed ? FMColors.green : FMColors.surface2)
                        .frame(width: 18, height: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                    agreed
                                        ? FMColors.green
                                        : FMColors.border,
                                    lineWidth: 1
                                )
                        )

                    if agreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(FMColors.background)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.top, 1)

            // Terms text
            Group {
                Text("I agree to the ")
                    .foregroundColor(FMColors.cream.opacity(0.28)) +
                Text("Terms of Service")
                    .foregroundColor(FMColors.cream.opacity(0.55))
                    .underline() +
                Text(" and ")
                    .foregroundColor(FMColors.cream.opacity(0.28)) +
                Text("Privacy Policy")
                    .foregroundColor(FMColors.cream.opacity(0.55))
                    .underline()
            }
            .font(.system(size: 13))
            .lineSpacing(3)
        }
    }
}
