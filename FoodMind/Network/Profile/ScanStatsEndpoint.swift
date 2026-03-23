//
//  ScanStatsEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

import Foundation

struct ScanStatsEndpoint: APIEndpoint {

    var headers: [String : String]? = nil

    var path: String {
        "/scan/stats/me"
    }

    var method: HTTPMethod {
        .GET
    }

    var body: Data? {
        nil
    }
}
