//
//  ViewController.swift
//  ExamplePNetworking
//
//  Created by Lucas Pham on 4/5/20.
//  Copyright © 2020 phthphat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let networking = PNetworkCaller(baseUrl: "https://api.themoviedb.org/3")
        
        let getAllEndpoint = ActorEndpoint.getAll
        networking.requestNormalData(endPoint: getAllEndpoint) { result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let err):
                print(err.message)
            }
        }
    }


}

enum ActorEndpoint {
    case getAll
}

extension ActorEndpoint: EndPoint {
    var path: String {
        switch self {
        case .getAll:
            return "/person/popular"
        default:
            return ""
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .getAll:
            return .get
        default:
            return .get
        }
    }
    
    var parameters: [String : Any] {
        var param = [String: Any]()
        param["api_key"] = "58d10a67ba0f9232e2f1b88e7e13cb1d"
        return param
    }
    
    var headers: [String : String]? {
        return nil
    }
}
