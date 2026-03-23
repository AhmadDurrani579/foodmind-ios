//
//  LoginEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//


import Foundation

struct LoginEndpoint: APIEndpoint {

    let request: LoginRequest

    var path: String { "/auth/login" }

    var method: HTTPMethod { .POST }

    var body: Data? {
        try? JSONEncoder().encode(request)
    }

    var headers: [String : String]? { nil }
}
