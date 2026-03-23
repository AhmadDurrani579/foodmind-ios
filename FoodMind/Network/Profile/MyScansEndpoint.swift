//
//  MyScansEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import Foundation

struct MyScansEndpoint: APIEndpoint {

    let limit: Int
    let offset: Int

    var headers: [String : String]? = nil

    var path: String {
        "/scan/me?limit=\(limit)&offset=\(offset)"
    }

    var method: HTTPMethod {
        .GET
    }

    var body: Data? {
        nil
    }
}
