//
//  AvatarPickerRow.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//

import SwiftUI

struct AvatarPickerRow: View {
 
    @State private var showImagePicker  = false
    @State private var selectedImage:   UIImage? = nil
 
    var body: some View {
        HStack(spacing: 14) {
 
            // ── Avatar circle ──────────────
            ZStack {
                Circle()
                    .fill(FMColors.surface2)
                    .frame(width: 54, height: 54)
 
                if let image = selectedImage {
                    // Show selected photo
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                } else {
                    // Show placeholder
                    Circle()
                        .stroke(
                            FMColors.cream.opacity(0.15),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                        )
                        .frame(width: 54, height: 54)
 
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                }
            }
            .onTapGesture {
                showImagePicker = true
            }
 
            // ── Info text ──────────────────
            VStack(alignment: .leading, spacing: 3) {
                Text("Profile photo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FMColors.cream)
                Text(
                    selectedImage == nil
                        ? "Tap to add a photo"
                        : "Tap to change photo"
                )
                .font(.system(size: 12))
                .foregroundColor(FMColors.cream.opacity(0.28))
            }
 
            Spacer()
 
            // ── Upload / Change button ─────
            Button(selectedImage == nil ? "Upload" : "Change") {
                showImagePicker = true
            }
            .font(.system(size: 13))
            .foregroundColor(FMColors.green)
        }
        .padding(14)
        .background(FMColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    selectedImage != nil
                        ? FMColors.green.opacity(0.3)
                        : FMColors.border,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: selectedImage != nil)
 
        // ── Present image picker ───────────
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}
