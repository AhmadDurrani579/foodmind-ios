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
    @EnvironmentObject var wsManager: WebSocketManager
    @StateObject private var metalProcessor = MetalProcessor()

    @StateObject private var cameraManager = CameraManager()
    @StateObject private var classifier    = FoodClassifierManager()
    @StateObject private var visionManager = VisionManager()
    @State private var frozenResult: FoodClassificationResult? = nil

    @State private var showImagePicker:  Bool             = false
    @State private var photosItem:       PhotosPickerItem? = nil
    @State private var selectedImage:    UIImage?          = nil
    @State private var showResult:       Bool              = false
    @State private var cameraMode:       CameraMode        = .scan
    @State private var isLiveMode:       Bool              = true
    @State private var classifyInterval: Int               = 0
    @State private var capturedFrame: UIImage? = nil
    @State private var metalInterval = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
 
            VStack(spacing: 0) {
                topBar
 
                ZStack {
                    if isLiveMode {
                        liveCameraView
                    } else if let image = selectedImage {
                        selectedImageView(image: image)
                    } else {
                        emptyStateView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
 
                bottomControls
            }
        }
        .onAppear {
            cameraManager.setup()
            setupClassifierCallback()
        }
        .onDisappear {
            cameraManager.stop()
        }
        .onChange(of: cameraManager.isAuthorized) {
            if cameraManager.isAuthorized {
        #if targetEnvironment(simulator)
        print("Running on Simulator")
        #else
        cameraManager.start()
        print("Running on Real Device")
        #endif
            }
        }
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $photosItem,
            matching: .images
        )
        .onChange(of: photosItem) {
            loadImage(from: photosItem)
        }
        // In CameraView — make sure onDismiss dismisses the sheet:
        .sheet(isPresented: $showResult) {
            if let frozenResult = frozenResult,
               let backendResult = wsManager.scanResult {
                ScanResultView(
                    result:        frozenResult,
                    backendResult: backendResult,
                    validation:    wsManager.validation,
                    image:         capturedFrame ?? selectedImage ?? UIImage(),
                    imageURL:      wsManager.imageURL,
                    onDismiss: {
                        showResult        = false
                        self.frozenResult = nil
                        wsManager.reset()
                        if isLiveMode { cameraManager.start() }
                    }
                ) .presentationDetents([.large])
                  .presentationDragIndicator(.visible)
                  .presentationCornerRadius(20)
            }
        }

        .onChange(of: wsManager.scanResult) {
            if wsManager.scanResult != nil {
                showResult = true
            }
        }

    }
 
    // ── Setup classifier callback ──
    private func setupClassifierCallback() {
        cameraManager.onFrame = { pixelBuffer in

            // Step 1: Detect plate distance
            self.visionManager.detectPlate(in: pixelBuffer)

            // ── Metal: Background thread, every 3rd frame ──
//            DispatchQueue.global(qos: .userInteractive).async {
//                self.metalInterval += 1
//                if self.metalInterval >= 3 {
//                    self.metalInterval = 0
//                    self.metalProcessor.process(
//                        pixelBuffer:  pixelBuffer,
//                        boundingBox:  self.visionManager.plateBoundingBox,
//                        confidence:   Float(self.classifier.result?.confidence ?? 0),
//                        hasDetection: self.visionManager.plateDistance.shouldClassify
//                    )
//                }
//            }

            DispatchQueue.main.async {
                self.classifyInterval += 1

                if self.classifyInterval >= 15 {
                    self.classifyInterval = 0

                    // Step 2: Only classify if close enough
                    guard self.visionManager.plateDistance
                        .shouldClassify else { return }

                    // ── Capture frame as UIImage ──────
                    self.capturedFrame = self.pixelBufferToUIImage(pixelBuffer)

                    // Step 3: Classify with crop
                    let box = self.visionManager.plateBoundingBox

                    if box != .zero {
                        self.classifier.classifyWithCrop(
                            pixelBuffer: pixelBuffer,
                            cropRect: box
                        )
                    } else {
                        self.classifier.classify(
                            pixelBuffer: pixelBuffer
                        )
                    }
                }
            }
        }
    }
    
    // Add this to CameraView:
    private func pixelBufferToUIImage(
        _ pixelBuffer: CVPixelBuffer
    ) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(
            ciImage,
            from: ciImage.extent
        ) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    
    // ── Top Bar ──
    private var topBar: some View {
        HStack {
            FMHeaderButton(icon: "xmark") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedTab = .feed
                }
            }
 
            Spacer()
 
            HStack(spacing: 0) {
                CameraModeButton(label: "Scan", isActive: cameraMode == .scan) { cameraMode = .scan }
                CameraModeButton(label: "Menu", isActive: cameraMode == .menu) { cameraMode = .menu }
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)
 
            Spacer()
 
            FMHeaderButton(icon: "bolt.slash") {
                cameraManager.toggleFlash()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }
 
    // ── Live Camera ──
    
    private var liveCameraView: some View {
        ZStack {
            if cameraManager.isAuthorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash")
                        .font(.system(size: 48))
                        .foregroundColor(FMColors.cream.opacity(0.3))
                    Text("Camera access required")
                        .font(.system(size: 16))
                        .foregroundColor(FMColors.cream.opacity(0.5))
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(FMColors.green)
                }
            }

            // ── Corner guides (confidence aware) ──
            CameraCorners(confidence: classifier.result?.confidence ?? 0)
                .frame(width: 240, height: 240)

            // ── Distance Guide ──────────────
            VStack {
                Spacer().frame(height: 80)
                if visionManager.plateDistance != .perfect
                   && visionManager.plateDistance != .unknown {
                    HStack(spacing: 8) {
                        Image(systemName: visionManager.plateDistance.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: visionManager.plateDistance.color))
                        Text(visionManager.plateDistance.message)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: visionManager.plateDistance.color))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.6))
                    .cornerRadius(20)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: visionManager.plateDistance.message)
                }
                Spacer()
            }

            // ── Result overlay ──────────────
            if let result = classifier.result {
                VStack {
                    Spacer()
                    resultOverlay(result: result)
                }
            }

            // ── Scanning tag ────────────────
            VStack {
                HStack {
                    Spacer()
                    if classifier.isRunning { scanningTag }
                    Spacer()
                }
                .padding(.top, 16)
                Spacer()
            }
        }
    }

 
    // ── Result Overlay ──
    private func resultOverlay(result: FoodClassificationResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.displayName)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .animation(.easeInOut(duration: 0.3), value: result.dishName)
                        .italic()
                        .foregroundColor(FMColors.cream)
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(hex: result.confidenceLevel.color))
                            .frame(width: 6, height: 6)
                        Text("\(result.confidencePercent)% · FoodClassifier")
                            .font(.system(size: 11))
                            .foregroundColor(FMColors.cream.opacity(0.55))
                    }
                }
                Spacer()
                Text("\(result.confidencePercent)%")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: result.confidenceLevel.color))
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.88), Color.black.opacity(0.5), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .animation(.easeInOut(duration: 0.3), value: result.dishName)
    }
 
    // ── Scanning Tag ──
    private var scanningTag: some View {
        HStack(spacing: 5) {
            Circle().fill(FMColors.green).frame(width: 5, height: 5)
            Text("Scanning")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(FMColors.green)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(FMColors.green.opacity(0.12))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(FMColors.green.opacity(0.25), lineWidth: 1))
    }
 
    // ── Selected Image ──
    private func selectedImageView(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
 
            if classifier.isRunning {
                Color.black.opacity(0.5)
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: FMColors.green))
                        .scaleEffect(1.4)
                    Text("Analysing...")
                        .font(.system(size: 13))
                        .foregroundColor(FMColors.cream.opacity(0.6))
                }
            }
 
            if let result = classifier.result, !classifier.isRunning {
                VStack { Spacer(); resultOverlay(result: result) }
            }
        }
    }
 
    // ── Empty State ──
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(FMColors.green.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                    .frame(width: 220, height: 220)
                CameraCorners().frame(width: 220, height: 220)
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 44))
                        .foregroundColor(FMColors.green.opacity(0.5))
                    Text("Pick a food photo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FMColors.cream.opacity(0.5))
                }
            }
        }
    }
 
    // ── Bottom Controls ──
    private var bottomControls: some View {
        VStack(spacing: 14) {
 
            // Result card
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(FMColors.surface)
                        .frame(width: 42, height: 42)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(FMColors.border, lineWidth: 1))
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(FMColors.green.opacity(0.6))
                }
 
                VStack(alignment: .leading, spacing: 2) {
                    if classifier.isRunning {
                        Text("Analysing...")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.5))
                    } else if let result = classifier.result {
                        Text(result.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .italic()
                            .foregroundColor(FMColors.cream)
                    } else {
                        Text("Point at food...")
                            .font(.system(size: 13))
                            .foregroundColor(FMColors.cream.opacity(0.3))
                    }
                    Text("FoodClassifier · Neural Engine")
                        .font(.system(size: 10))
                        .foregroundColor(FMColors.cream.opacity(0.2))
                }
 
                Spacer()
 
                if let result = classifier.result, !classifier.isRunning {
                    Text("\(result.confidencePercent)%")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: result.confidenceLevel.color))
                } else {
                    Text("—").font(.system(size: 18)).foregroundColor(FMColors.cream.opacity(0.2))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(FMColors.surface)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
 
            // Buttons row
            HStack {
                // Gallery
                Button {
                    isLiveMode = false
                    classifier.reset()
                    showImagePicker = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle").font(.system(size: 20)).foregroundColor(FMColors.cream.opacity(0.6))
                        Text("Gallery").font(.system(size: 10)).foregroundColor(FMColors.cream.opacity(0.3))
                    }
                    .frame(width: 56, height: 56)
                    .background(FMColors.surface2)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
                }
 
                Spacer()
 
                // Shutter
                Button {
                    print("🔘 Deep Scan tapped")
                    print("🔍 classifier.result: \(String(describing: classifier.result))")
                    print("🖼️ selectedImage: \(String(describing: selectedImage))")
                    print("🔌 wsManager state: \(wsManager.connectionState)")

                    if let result = classifier.result {
                        frozenResult = result
                        cameraManager.stop()
                        let imageToSend = isLiveMode ? capturedFrame : selectedImage
                        
                        print("🖼️ capturedFrame: \(String(describing: capturedFrame))")
                        print("🖼️ imageToSend: \(String(describing: imageToSend))")


                        // Send to backend
                        if let image = imageToSend {
                            wsManager.sendScan(
                                image: image,
                                mobileNetResult: result
                            )
                        }
                        // Don't open sheet yet ← key change
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(FMColors.green.opacity(0.3), lineWidth: 3)
                            .frame(width: 72, height: 72)

                        Circle()
                            .fill(
                                wsManager.isScanning
                                    ? FMColors.surface2
                                    : classifier.result != nil
                                        ? FMColors.green
                                        : FMColors.surface2
                            )
                            .frame(width: 62, height: 62)

                        // Show spinner while waiting for backend
                        if wsManager.isScanning {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: FMColors.green)
                                )
                        } else {
                            Image(systemName: classifier.result != nil
                                ? "arrow.right.circle.fill"
                                : "viewfinder"
                            )
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(
                                classifier.result != nil
                                    ? FMColors.background
                                    : FMColors.cream.opacity(0.3)
                            )
                        }
                    }
                }

                
                Spacer()
 
                // Flip / Camera toggle
                Button {
                    if isLiveMode {
                        cameraManager.flipCamera()
                    } else {
                        isLiveMode = true
                        classifier.reset()
                        cameraManager.start()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: isLiveMode ? "arrow.triangle.2.circlepath" : "camera.fill")
                            .font(.system(size: 20)).foregroundColor(FMColors.cream.opacity(0.6))
                        Text(isLiveMode ? "Flip" : "Camera")
                            .font(.system(size: 10)).foregroundColor(FMColors.cream.opacity(0.3))
                    }
                    .frame(width: 56, height: 56)
                    .background(FMColors.surface2)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(FMColors.border, lineWidth: 1))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.85).ignoresSafeArea(edges: .bottom))
    }
 
    private func captureCurrentFrame() -> UIImage? {
        // If in gallery mode return selected image
        if !isLiveMode { return selectedImage }

        // For live camera capture current frame
        // For now return nil — live capture
        // requires AVCapturePhotoOutput
        // We'll add this next
        return nil
    }

    // ── Load image from picker ──
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                    isLiveMode    = false
                    cameraManager.stop()
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





