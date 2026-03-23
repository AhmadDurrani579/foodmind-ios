//  CameraPreviewView.swift
//  FoodMind
//
//  Created by Ahmad on 14/03/2026.


import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        // Fix iOS 17 deprecation
        if let connection = view.videoPreviewLayer.connection {
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 90 // portrait
            }
        }

        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        if let connection = uiView.videoPreviewLayer.connection {
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 90 // portrait
            }
        }
    }
}

class PreviewUIView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
