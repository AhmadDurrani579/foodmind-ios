//
//  SignupEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//

import Foundation

struct SignupEndpoint: APIEndpoint {

    let request: SignupRequest
    var path: String {
        "/auth/signup"
    }
    var method: HTTPMethod {
        .POST
    }
    var body: Data? {
        try? JSONEncoder().encode(request)
    }
    var headers: [String : String]? {
        nil
    }
}
