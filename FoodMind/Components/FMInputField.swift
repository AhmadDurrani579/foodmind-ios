//
//  FMInputField.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct FMInputField: View {
    let label:        String
    let placeholder:  String
    @Binding var text: String
    var icon:         String      = ""
    var keyboardType: UIKeyboardType = .default
    var autoCapitalize: Bool      = true
 
    @FocusState private var isFocused: Bool
 
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
 
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(FMColors.cream.opacity(0.28))
                .tracking(1.2)
 
            HStack(spacing: 10) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(
                            isFocused
                                ? FMColors.green.opacity(0.8)
                                : FMColors.cream.opacity(0.25)
                        )
                }
 
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(autoCapitalize ? .words : .none)
                    .autocorrectionDisabled()
                    .font(.system(size: 15))
                    .foregroundColor(FMColors.cream)
                    .focused($isFocused)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(FMColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused
                            ? FMColors.green.opacity(0.5)
                            : FMColors.border,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}
