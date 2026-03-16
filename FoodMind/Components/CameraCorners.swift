//
//  CameraCorners.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI

struct CameraCorners: View {
    var body: some View {
        ZStack {
            // Top left
            CornerShape()
                .stroke(Color(hex: "8DB87A"), lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .offset(x: -110, y: -110)
 
            // Top right
            CornerShape()
                .stroke(Color(hex: "8DB87A"), lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(90))
                .offset(x: 110, y: -110)
 
            // Bottom left
            CornerShape()
                .stroke(Color(hex: "8DB87A"), lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(270))
                .offset(x: -110, y: 110)
 
            // Bottom right
            CornerShape()
                .stroke(Color(hex: "8DB87A"), lineWidth: 2.5)
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(180))
                .offset(x: 110, y: 110)
        }
    }
}
