//
//  ImagePicker.swift
//  FoodMind
//
//  Created by Ahmad on 13/03/2026.
//
import SwiftUI
import PhotosUI

// ─────────────────────────────────────
// MARK: — ImagePicker
// Wraps PHPickerViewController for SwiftUI
// Usage: .sheet(isPresented: $show) { ImagePicker(image: $selectedImage) }
// ─────────────────────────────────────
struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    // ── Coordinator ───────────────────
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // ── Make the PHPickerViewController ──
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter          = .images   // photos only
        config.selectionLimit  = 1         // one image at a time
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // ── Coordinator (handles delegate) ──
    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            // User cancelled
            guard let result = results.first else {
                parent.dismiss()
                return
            }

            // Load the image
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self.parent.image = image
                    }
                    self.parent.dismiss()
                }
            }
        }
    }
}
