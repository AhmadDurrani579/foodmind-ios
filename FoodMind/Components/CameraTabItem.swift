//
//  CameraTabItem.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct CameraTabItem: View {
 
    @Binding var selectedTab: FMTab
 
    var isActive: Bool { selectedTab == .camera }
 
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = .camera
            }
        } label: {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        isActive
                            ? Color(hex: "8DB87A").opacity(0.4)
                            : Color.white.opacity(0.1),
                        lineWidth: 1.5
                    )
                    .frame(width: 52, height: 52)
 
                // Inner fill
                Circle()
                    .fill(
                        isActive
                            ? Color(hex: "8DB87A")
                            : Color(hex: "1C1D17")
                    )
                    .frame(width: 44, height: 44)
 
                // Icon
                Image(systemName: "viewfinder")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        isActive
                            ? Color(hex: "0C0D09")
                            : Color(hex: "F5EDD6").opacity(0.6)
                    )
            }
            .frame(maxWidth: .infinity)
            .offset(y: -8) // lifts camera button up slightly
        }
        .animation(.spring(response: 0.3), value: isActive)
    }
}
