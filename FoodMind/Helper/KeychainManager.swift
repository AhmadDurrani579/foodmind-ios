//
//  KeychainManager.swift
//  FoodMind
//
//  Created by Ahmad on 22/03/2026.
//

import Foundation

class KeychainManager {
    static let shared = KeychainManager()
    private let key = "com.foodmind.faceEmbedding"

    func saveFaceEmbedding(_ embedding: [Float]) {
        let data = Data(bytes: embedding, count: embedding.count * MemoryLayout<Float>.size)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)   // delete old first
        SecItemAdd(query as CFDictionary, nil)
    }

    func loadFaceEmbedding() -> [Float]? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        let count = data.count / MemoryLayout<Float>.size
        return data.withUnsafeBytes { Array($0.bindMemory(to: Float.self).prefix(count)) }
    }

    func deleteFaceEmbedding() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
