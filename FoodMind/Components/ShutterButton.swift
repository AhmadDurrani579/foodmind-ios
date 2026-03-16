//
//  ShutterButton.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct ShutterButton: View {
    var action: () -> Void
 
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 72, height: 72)
                Circle()
                    .fill(Color(hex: "8DB87A"))
                    .frame(width: 60, height: 60)
                Image(systemName: "viewfinder")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color(hex: "0C0D09"))
            }
        }
    }
}
