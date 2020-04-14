//
//  EndPointType.swift
//
//  Created by Phat Pham on 12/17/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation

public protocol EndPoint {
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var parameters: [String: Any] { get }
    var headers: [String: String]? { get }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum NetworkError: Error {
    case badUrl
    case network(msg: String)
    case custom(msg: String)
    
    var message: String {
        switch self {
        case .badUrl:
            return "Bad or invalid url"
        case .custom(let msg), .network(let msg):
            return msg
//        default:
//            return self.localizedDescription
        }
    }
}
