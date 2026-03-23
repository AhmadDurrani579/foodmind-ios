//
//  APIEndpoint.swift
//  FoodMind
//
//  Created by Ahmad on 17/03/2026.
//

import Foundation

protocol APIEndpoint {
    
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
}
