//
//  UploadAvatarEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


import Foundation

struct UploadAvatarEndpoint: APIEndpoint {

    let bodyData: Data
    let boundary: String

    var path: String { "/auth/users/avatar" }

    var method: HTTPMethod { .POST }

    var body: Data? { bodyData }

    var headers: [String : String]? {
        [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
    }
}
