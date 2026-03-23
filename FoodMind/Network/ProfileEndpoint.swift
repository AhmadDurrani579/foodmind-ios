//
//  ProfileEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//
import Foundation

struct ProfileEndpoint: APIEndpoint {

    var headers: [String : String]? = nil

    var path: String {
        "/users/me"
    }

    var method: HTTPMethod {
        .GET
    }

    var body: Data? {
        nil
    }
}
