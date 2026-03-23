//
//  FaceRecognitionManager.swift
//  FoodMind
//
//  Created by Ahmad on 22/03/2026.
//
import Foundation
import UIKit

class FaceRecognitionManager {
    static let shared = FaceRecognitionManager()
 
    enum AuthResult {
        case success
        case notRegistered
        case failed(String)
    }
 
    func authenticate(from image: UIImage, completion: @escaping (AuthResult) -> Void) {
        // Check if registered first
        guard KeychainManager.shared.loadFaceEmbedding() != nil else {
            completion(.notRegistered)
            return
        }
        // Run full recognition pipeline here
        // (paste full implementation from previous message)
        completion(.success)   // placeholder
    }
 
    func register(from image: UIImage, completion: @escaping (Bool) -> Void) {
        // Run FaceNet, store embedding in Keychain
        // (paste full implementation from previous message)
        completion(true)   // placeholder
    }
}


