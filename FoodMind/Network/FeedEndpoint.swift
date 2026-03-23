//
//  FeedEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//


import Foundation

struct FeedEndpoint: APIEndpoint {

    let limit: Int
    let offset: Int

    var headers: [String : String]? {
        nil
    }

    var path: String {
        "/posts/feed?limit=\(limit)&offset=\(offset)"
    }

    var method: HTTPMethod {
        .GET
    }

    var body: Data? {
        nil
    }
}
