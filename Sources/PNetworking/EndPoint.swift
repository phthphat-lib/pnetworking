//
//  EndPointType.swift
//  BaseProject
//
//  Created by Lucas Pham on 12/17/19.
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

