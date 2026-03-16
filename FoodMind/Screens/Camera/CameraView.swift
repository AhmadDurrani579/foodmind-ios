//
//  CameraView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
 
    @Binding var selectedTab: FMTab
 
    // ── State ─────────────────────────
    @StateObject private var classifier = FoodClassifierManager()
    @State private var selectedImage:  UIImage?    = nil
    @State private var showImagePicker: Bool       = false
    @State private var photosItem:     PhotosPickerItem? = nil
    @State private var showResult:     Bool        = false
    @State private var cameraMode:     CameraMode  = .scan
 
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                // ── Top Bar ─────────────────
                topBar
 
                // ── Main Content ────────────
                ZStack {
                    if let image = selectedImage {
                        // Show selected image
                        selectedImageView(image: image)
                    } else {
                        // Show empty state
                        emptyStateView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
 
                // ── Bottom Controls ─────────
                bottomControls
            }
        }
        // Image picker
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $photosItem,
            matching: .images
        )
        .onChange(of: photosItem) {
            loadImage(from: photosItem)
        }
        // Result sheet
        .sheet(isPresented: $showResult) {
            if let result = classifier.result,
               let image = selectedImage {
                ScanResultView(
                    result: result,
                    image: image,
                    onDismiss: {
                        showResult = false
                    }
                )
            }
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Top Bar
    // ─────────────────────────────────
    private var topBar: some View {
        HStack {
            // X button → goes back to feed
            FMHeaderButton(icon: "xmark") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedTab = .feed
                }
            }
 
            Spacer()
 
            // Scan / Menu toggle
            HStack(spacing: 0) {
                CameraModeButton(
                    label: "Scan",
                    isActive: cameraMode == .scan
                ) {
                    cameraMode = .scan
                }
                CameraModeButton(
                    label: "Menu",
                    isActive: cameraMode == .menu
                ) {
                    cameraMode = .menu
                }
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)
 
            Spacer()
 
            // Flash placeholder
            FMHeaderButton(icon: "bolt.slash")
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }
 
    // ─────────────────────────────────
    // MARK: — Empty State
    // ─────────────────────────────────
    private var emptyStateView: some View {
        VStack(spacing: 24) {
 
            // Animated viewfinder
            ZStack {
                // Corner guides
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        FMColors.green.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [8, 4]
                        )
                    )
                    .frame(width: 220, height: 220)
 
                CameraCorners()
                    .frame(width: 220, height: 220)
 
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 44))
                        .foregroundColor(FMColors.green.opacity(0.5))
 
                    Text("Pick a food photo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FMColors.cream.opacity(0.5))
 
                    Text("Tap the gallery button below")
                        .font(.system(size: 12))
                        .foregroundColor(FMColors.cream.opacity(0.25))
                }
            }
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Selected Image View
    // ─────────────────────────────────
    private func selectedImageView(image: UIImage) -> some View {
        ZStack {
            // Image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
 
            // Loading overlay
            if classifier.isRunning {
                ZStack {
                    Color.black.opacity(0.5)
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: FMColors.green)
                            )
                            .scaleEffect(1.5)
 
                        Text("Analysing food...")
                            .font(.system(size: 14))
                            .foregroundColor(FMColors.cream.opacity(0.7))
 
                        Text("MobileNet · Neural Engine")
                            .font(.system(size: 11))
                            .foregroundColor(FMColors.cream.opacity(0.35))
                    }
                }
            }
 
            // Result overlay (when done)
            if let result = classifier.result,
               !classifier.isRunning {
                VStack {
                    Spacer()
                    resultOverlay(result: result)
                }
            }
 
            // Error overlay
            if let error = classifier.error {
                VStack {
                    Spacer()
                    errorOverlay(error: error)
                }
            }
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Result Overlay
    // ─────────────────────────────────
    private func resultOverlay(result: FoodClassificationResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
 
            // Dish name + confidence
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.displayName)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .italic()
                        .foregroundColor(FMColors.cream)
 
                    HStack(spacing: 6) {
                        // Confidence dot
                        Circle()
                            .fill(Color(hex: result.confidenceLevel.color))
                            .frame(width: 6, height: 6)
 
                        Text("\(result.confidencePercent)% confident")
                            .font(.system(size: 12))
                            .foregroundColor(FMColors.cream.opacity(0.6))
 
                        Text("·")
                            .foregroundColor(FMColors.cream.opacity(0.3))
 
                        Text("MobileNet")
                            .font(.system(size: 12))
                            .foregroundColor(FMColors.cream.opacity(0.35))
                    }
                }
 
                Spacer()
 
                // Confidence badge
                Text("\(result.confidencePercent)%")
                    .font(.system(
                        size: 22,
                        weight: .bold,
                        design: .serif
                    ))
                    .foregroundColor(Color(hex: result.confidenceLevel.color))
            }
 
            // Top 3 alternatives
            if result.allResults.count > 1 {
                HStack(spacing: 6) {
                    Text("Also:")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.3))
 
                    ForEach(
                        Array(result.allResults.dropFirst().prefix(2)),
                        id: \.label
                    ) { item in
                        Text(item.label
                            .replacingOccurrences(of: "_", with: " ")
                            .capitalized
                        )
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.4))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.6),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
 
    // ─────────────────────────────────
    // MARK: — Error Overlay
    // ─────────────────────────────────
    private func errorOverlay(error: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(FMColors.orange)
            Text(error)
                .font(.system(size: 13))
                .foregroundColor(FMColors.cream.opacity(0.7))
        }
        .padding(14)
        .background(Color.black.opacity(0.8))
    }
 
    // ─────────────────────────────────
    // MARK: — Bottom Controls
    // ─────────────────────────────────
    private var bottomControls: some View {
        VStack(spacing: 14) {
 
            // MobileNet result card
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(FMColors.surface)
                        .frame(width: 42, height: 42)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(FMColors.border, lineWidth: 1)
                        )
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(FMColors.green.opacity(0.6))
                }
 
                VStack(alignment: .leading, spacing: 2) {
                    if classifier.isRunning {
                        Text("Analysing...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(FMColors.cream.opacity(0.6))
                    } else if let result = classifier.result {
                        Text(result.displayName)
                            .font(.system(
                                size: 14,
                                weight: .semibold,
                                design: .serif
                            ))
                            .foregroundColor(FMColors.cream)
                            .italic()
                    } else {
                        Text("Waiting for food...")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.4))
                    }
 
                    Text("MobileNet · Neural Engine")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                }
 
                Spacer()
 
                // Confidence score
                if let result = classifier.result,
                   !classifier.isRunning {
                    Text("\(result.confidencePercent)%")
                        .font(.system(
                            size: 20,
                            weight: .semibold,
                            design: .serif
                        ))
                        .foregroundColor(
                            Color(hex: result.confidenceLevel.color)
                        )
                } else {
                    Text("—")
                        .font(.system(size: 18))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(FMColors.surface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FMColors.border, lineWidth: 1)
            )
 
            // Action buttons row
            HStack {
 
                // Gallery button
                Button {
                    classifier.reset()
                    showImagePicker = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                            .foregroundColor(FMColors.cream.opacity(0.6))
                        Text("Gallery")
                            .font(.system(size: 10))
                            .foregroundColor(FMColors.cream.opacity(0.3))
                    }
                    .frame(width: 56, height: 56)
                    .background(FMColors.surface2)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(FMColors.border, lineWidth: 1)
                    )
                }
 
                Spacer()
 
                // Main scan button
                Button {
                    if selectedImage == nil {
                        showImagePicker = true
                    } else if classifier.result != nil {
                        showResult = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                FMColors.green.opacity(0.3),
                                lineWidth: 3
                            )
                            .frame(width: 72, height: 72)
 
                        Circle()
                            .fill(
                                classifier.result != nil
                                    ? FMColors.green
                                    : FMColors.surface2
                            )
                            .frame(width: 62, height: 62)
 
                        if classifier.isRunning {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: FMColors.background
                                    )
                                )
                        } else {
                            Image(systemName:
                                classifier.result != nil
                                    ? "arrow.right.circle.fill"
                                    : "viewfinder"
                            )
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(
                                classifier.result != nil
                                    ? FMColors.background
                                    : FMColors.cream.opacity(0.4)
                            )
                        }
                    }
                }
                .disabled(classifier.isRunning)
 
                Spacer()
 
                // Deep scan button (sends to backend)
                Button {
                    // TODO: Send to backend via WebSocket
                    // Coming tomorrow
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "waveform.and.magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(
                                classifier.result != nil
                                    ? FMColors.green.opacity(0.7)
                                    : FMColors.cream.opacity(0.2)
                            )
                        Text("Deep Scan")
                            .font(.system(size: 10))
                            .foregroundColor(
                                classifier.result != nil
                                    ? FMColors.green.opacity(0.5)
                                    : FMColors.cream.opacity(0.2)
                            )
                    }
                    .frame(width: 56, height: 56)
                    .background(FMColors.surface2)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                classifier.result != nil
                                    ? FMColors.green.opacity(0.2)
                                    : FMColors.border,
                                lineWidth: 1
                            )
                    )
                }
                .disabled(classifier.result == nil)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color.black.opacity(0.85)
                .ignoresSafeArea(edges: .bottom)
        )
    }
 
    // ─────────────────────────────────
    // MARK: — Load Image From Picker
    // ─────────────────────────────────
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
 
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
 
                await MainActor.run {
                    selectedImage = image
                    // Classify immediately
                    classifier.classify(image: image)
                }
            }
        }
    }
}

 
enum CameraMode {
    case scan
    case menu
}
