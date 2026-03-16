//
//  PasswordStrengthBar.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct PasswordStrengthBar: View {

    let password: String

    private var strength: PasswordStrength {
        if password.count < 6               { return .weak }
        if password.count < 10              { return .medium }
        let hasUpper   = password.contains(where: \.isUppercase)
        let hasNumber  = password.contains(where: \.isNumber)
        let hasSpecial = password.contains(where: { "!@#$%^&*".contains($0) })
        return (hasUpper && hasNumber && hasSpecial) ? .strong : .medium
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PasswordStrength.allCases, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        strength.rawValue >= level.rawValue
                            ? strength.color
                            : FMColors.surface2
                    )
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: strength)
            }

            Text(strength.label)
                .font(.system(size: 11))
                .foregroundColor(strength.color)
                .frame(width: 50, alignment: .trailing)
        }
    }
}
