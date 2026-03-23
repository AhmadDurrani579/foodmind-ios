//
//  MultipartFormDataBuilder.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


import Foundation
import UIKit

class MultipartFormDataBuilder {

    static func build(image: UIImage) -> Data {

        let boundary = UUID().uuidString
        var data = Data()

        let imageData = image.jpegData(compressionQuality: 0.8)!

        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n")
        data.append("Content-Type: image/jpeg\r\n\r\n")
        data.append(imageData)
        data.append("\r\n")
        data.append("--\(boundary)--\r\n")

        return data
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) {
            append(d)
        }
    }
}