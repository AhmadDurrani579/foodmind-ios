//
//  SocialLoginRow.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct SocialLoginRow: View {
    var onApple:  () -> Void
    var onGoogle: () -> Void
 
    var body: some View {
        HStack(spacing: 10) {
            SocialButton(
                icon:  "apple.logo",
                label: "Apple",
                action: onApple
            )
            SocialButton(
                icon:  "globe",
                label: "Google",
                action: onGoogle
            )
        }
    }
}
