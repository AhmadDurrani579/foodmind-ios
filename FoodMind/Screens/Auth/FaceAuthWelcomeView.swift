//
//  FaceAuthWelcomeView.swift
//  FoodMind
//
//  Created by Ahmad on 22/03/2026.
//
import SwiftUI


struct FaceAuthWelcomeView: View {
 
    // ── Callbacks ─────────────────────
    var onFaceSuccess: () -> Void     // face recognised → go to main app
    var onUseEmail:    () -> Void     // use email → go to existing LoginView
 
    // ── State ─────────────────────────
    @State private var showCamera      = false
    @State private var isScanning      = false
    @State private var scanFailed      = false
    @State private var errorMessage    = ""
    @State private var buttonScale     = 1.0
    @State private var logoScale       = 0.8
    @State private var contentOpacity  = 0.0
 
    var body: some View {
        ZStack {
            // ── Background ──
            Color.black.ignoresSafeArea()
 
            VStack(spacing: 0) {
 
                Spacer()
 
                // ── Logo ──
                Text("🍔")
                    .font(.system(size: 64))
                    .scaleEffect(logoScale)
                    .padding(.bottom, 28)
 
                // ── Title ──
                Text("Sign in to FoodMind")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
 
                // ── Subtitle ──
                Text("Use face recognition to sign in instantly.\nNo password needed.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 32)
 
                // ── Feature rows ──
                VStack(spacing: 18) {
                    FeatureRow(
                        icon: "lock.shield.fill",
                        iconColor: Color(red: 0.55, green: 0.72, blue: 0.48),
                        text: "Your face data never leaves your device — processed entirely on-device"
                    )
                    FeatureRow(
                        icon: "bolt.fill",
                        iconColor: Color(red: 0.95, green: 0.79, blue: 0.30),
                        text: "Sign in in under a second, every time"
                    )
                    FeatureRow(
                        icon: "checkmark.shield.fill",
                        iconColor: Color(red: 0.48, green: 0.72, blue: 0.85),
                        text: "No server storage — your face never leaves this phone"
                    )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
 
                // ── Error message ──
                if scanFailed {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.89, green: 0.35, blue: 0.35))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
 
                // ── Face Recognition button ──
                Button {
                    triggerFaceScan()
                } label: {
                    HStack(spacing: 12) {
                        if isScanning {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                        }
                        Text(isScanning ? "Scanning..." : "Continue with Face Recognition")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        isScanning
                            ? Color(red: 0.08, green: 0.50, blue: 0.36)
                            : Color(red: 0.11, green: 0.62, blue: 0.46)
                    )
                    .cornerRadius(16)
                    .scaleEffect(buttonScale)
                }
                .disabled(isScanning)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .onLongPressGesture(
                    minimumDuration: 0,
                    pressing: { pressing in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            buttonScale = pressing ? 0.97 : 1.0
                        }
                    }, perform: {}
                )
 
                // ── Email fallback ──
                Button {
                    onUseEmail()
                } label: {
                    Text("Use email instead")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
 
                Spacer().frame(height: 40)
            }
            .opacity(contentOpacity)
        }
        // ── Camera sheet ──
        .fullScreenCover(isPresented: $showCamera) {
            FaceCaptureView(
                onCapture: { image in
                    showCamera = false
                    processFace(image: image)
                },
                onCancel: {
                    showCamera = false
                    isScanning = false
                }
            )
        }
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale    = 1.0
                contentOpacity = 1.0
            }
 
            // Check if face already registered — auto-trigger scan
            if KeychainManager.shared.loadFaceEmbedding() != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    triggerFaceScan()
                }
            }
        }
    }
 
    // ─────────────────────────────────
    // MARK: — Actions
    // ─────────────────────────────────
    private func triggerFaceScan() {
        withAnimation { scanFailed = false }
        isScanning = true
        showCamera = true
    }
 
    private func processFace(image: UIImage) {
        FaceRecognitionManager.shared.authenticate(from: image) { result in
            DispatchQueue.main.async {
                isScanning = false
                switch result {
                case .success:
                    // Face matched — go to main app
                    withAnimation(.easeInOut(duration: 0.4)) {
                        onFaceSuccess()
                    }
                case .notRegistered:
                    // First time — register then proceed
                    FaceRecognitionManager.shared.register(from: image) { registered in
                        DispatchQueue.main.async {
                            if registered {
                                withAnimation { onFaceSuccess() }
                            } else {
                                showError("Could not register face — try better lighting")
                            }
                        }
                    }
                case .failed(let msg):
                    showError(msg)
                }
            }
        }
    }
 
    private func showError(_ message: String) {
        errorMessage = message
        withAnimation(.easeInOut) { scanFailed = true }
        // Auto hide after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation { scanFailed = false }
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — Feature Row
// ─────────────────────────────────────
private struct FeatureRow: View {
    let icon:      String
    let iconColor: Color
    let text:      String
 
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24)
 
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.55))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
 
            Spacer()
        }
    }
}
 
// ─────────────────────────────────────
// MARK: — Face Capture View
// Shows camera, captures a single frame for recognition
// ─────────────────────────────────────
struct FaceCaptureView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void
    var onCancel:  () -> Void
 
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker            = UIImagePickerController()
        picker.sourceType     = .camera
        picker.cameraDevice   = .front
        picker.delegate       = context.coordinator
        picker.showsCameraControls = true
        return picker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: Context) {}
 
    func makeCoordinator() -> Coordinator { Coordinator(self) }
 
    class Coordinator: NSObject, UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate {
        let parent: FaceCaptureView
        init(_ parent: FaceCaptureView) { self.parent = parent }
 
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            } else {
                parent.onCancel()
            }
        }
 
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}
