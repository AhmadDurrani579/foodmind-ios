//
//  CreatePostEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import Foundation

struct CreatePostEndpoint: APIEndpoint {

    let request: CreatePostRequest

    var path: String {
        "/posts"
    }

    var method: HTTPMethod {
        .POST
    }

    var body: Data? {
        try? JSONEncoder().encode(request)
    }

    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}
