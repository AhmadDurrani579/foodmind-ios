//
//  FMTabItem.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct FMTabItem: View {
 
    let icon:       String
    let label:      String
    let tab:        FMTab
    @Binding var selectedTab: FMTab
 
    var isActive: Bool { selectedTab == tab }
 
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(
                        size: 18,
                        weight: isActive ? .semibold : .regular
                    ))
                    .foregroundColor(
                        isActive
                            ? Color(hex: "8DB87A")
                            : Color(hex: "F5EDD6").opacity(0.25)
                    )
                    .scaleEffect(isActive ? 1.05 : 1.0)
 
                Circle()
                    .fill(Color(hex: "8DB87A"))
                    .frame(width: 4, height: 4)
                    .opacity(isActive ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.3), value: isActive)
    }
}
