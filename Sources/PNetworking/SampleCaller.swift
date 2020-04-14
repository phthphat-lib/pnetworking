//
//  SampleCaller.swift
//
//  Created by Lucas Pham on 4/14/20.
//  Copyright © 2020 phthphat. All rights reserved.
//

import Foundation


//Sample a caller
public struct PNetworkCaller: PNetworking {
    public var baseUrl: String
    public init(baseUrl: String){
        self.baseUrl = baseUrl
    }
}
