//
//  FoodARView.swift
//  FoodMind
//
//  Created by Ahmad on 19/03/2026.
//


import SwiftUI
import ARKit
import SceneKit
 
// ─────────────────────────────────────
// MARK: — FoodARView
// SwiftUI wrapper for ARKit experience
// Presented as sheet from ScanResultView
// ─────────────────────────────────────
struct FoodARView: View {
 
    // ── Data from scan ────────────────
    let backendResult: BackendScanResult
    let yoloBBox:      [Double]          // normalised [x,y,w,h]
    let foodImage:     UIImage?
    let modelURL:      String?
    
    // ── State ─────────────────────────
    @Environment(\.dismiss) var dismiss
    @State private var isPlaced      = false
    @State private var statusMessage = "Move camera to find a surface"
    @State private var showTip       = true
    @State private var selectedIngredient: ScanIngredient? = nil
    @State private var showIngredientDetail = false

    var body: some View {
        ZStack {
 
            // ── ARKit Camera View ─────────
            FoodARViewContainer(
                backendResult: backendResult,
                yoloBBox:      yoloBBox,
                foodImage:     foodImage,
                modelURL:      modelURL,
                isPlaced:      $isPlaced,
                statusMessage: $statusMessage,
                selectedIngredient:   $selectedIngredient,    // ← ADD
                showIngredientDetail: $showIngredientDetail   // ← ADD

            )
            .ignoresSafeArea()
 
            // ── UI Overlay ────────────────
            VStack {
 
                // ── Top bar ───────────────
                HStack(spacing: 10) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 34, height: 34)
                            .background(.black.opacity(0.72))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Combined pill: name + divider + kcal
                    HStack(spacing: 0) {
                        Text(backendResult.dish_name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)

                        Rectangle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 1, height: 20)

                        Text("\(backendResult.calories) kcal")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(FMColors.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .background(.black.opacity(0.72))
                    .cornerRadius(20)

                    Spacer()

                    // Confidence badge
                    Text("\(backendResult.confidence)%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(FMColors.green)
                        .frame(width: 34, height: 34)
                        .background(.black.opacity(0.72))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                Spacer()
 
                // ── Status message ────────
                if !isPlaced {
                    VStack(spacing: 8) {
 
                        // Animated scanning indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(FMColors.green)
                                .frame(width: 6, height: 6)
                            Text(statusMessage)
                                .font(.system(size: 13))
                                .foregroundColor(FMColors.cream)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.6))
                        .cornerRadius(20)
 
                        // Tip
                        if showTip {
                            Text("Point camera anywhere and tap to place")
                                .font(.system(size: 11))
                                .foregroundColor(FMColors.cream.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 40)
                }
 
                // ── Placed success bar ────
                if isPlaced {
                    VStack(spacing: 8) {
                        // Macro strip
                        HStack(spacing: 8) {
                            MacroPill(label: "\(backendResult.fat_g )g fat",    color: FMColors.orange)
                            MacroPill(label: "\(backendResult.carbs_g)g carbs", color: FMColors.green)
                            MacroPill(label: "\(backendResult.protein_g)g prot", color: Color(red: 0.22, green: 0.55, blue: 0.85))
                        }

                        // Status row
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(FMColors.green)
                                .font(.system(size: 14))
                            Text("Tap any label for details")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Button("Reset") {
                                isPlaced      = false
                                statusMessage = "Move camera to find a surface"
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(FMColors.green)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.75))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }

            }
 
            // ── Crosshair (before placed) ──
            if !isPlaced {
                CrosshairView()
            }
        }.sheet(isPresented: $showIngredientDetail) {
            if let ingredient = selectedIngredient {
                IngredientDetailView(
                    ingredient:    ingredient,
                    totalCalories: backendResult.calories,
                    onLog: {
                        // hook into your diary manager here
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
            }
        }
        .onAppear {
            // Hide tip after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showTip = false }
            }
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — ARKit Container
// UIViewControllerRepresentable
// ─────────────────────────────────────
struct FoodARViewContainer: UIViewControllerRepresentable {
 
    let backendResult: BackendScanResult
    let yoloBBox:      [Double]
    let foodImage:     UIImage?
    let modelURL:      String?
    @Binding var isPlaced:      Bool
    @Binding var statusMessage: String
    @Binding var selectedIngredient: ScanIngredient?   // ← ADD
    @Binding var showIngredientDetail: Bool             // ← ADD

    func makeUIViewController(
        context: Context
    ) -> FoodARViewController {
        let vc = FoodARViewController()
        vc.backendResult  = backendResult
        vc.yoloBBox       = yoloBBox
        vc.foodImage     = foodImage
        vc.modelURL       = modelURL
        vc.onPlaced       = { isPlaced = true }
        vc.onStatusChange = { msg in statusMessage = msg }
        
        vc.onIngredientTapped = { ingredient in
            selectedIngredient   = ingredient
            showIngredientDetail = true
        }

        return vc
    }
 
    func updateUIViewController(
        _ uiViewController: FoodARViewController,
        context: Context
    ) {}
}
 
// ─────────────────────────────────────
// MARK: — Crosshair View
// Shows before surface is found
// ─────────────────────────────────────
struct CrosshairView: View {
 
    @State private var pulse = false
 
    var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(FMColors.green.opacity(0.6))
                .frame(width: 24, height: 1.5)
 
            // Vertical line
            Rectangle()
                .fill(FMColors.green.opacity(0.6))
                .frame(width: 1.5, height: 24)
 
            // Centre dot
            Circle()
                .fill(FMColors.green)
                .frame(width: 5, height: 5)
                .scaleEffect(pulse ? 1.5 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: pulse
                )
        }
        .onAppear { pulse = true }
    }
}

private struct MacroPill: View {
    let label: String
    let color: Color
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(10)
    }
}
