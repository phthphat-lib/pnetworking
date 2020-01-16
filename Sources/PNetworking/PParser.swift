//
//  JSONParser.swift
//  ComplicatedGroupChat
//
//  Created by Lucas Pham on 12/15/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation

open class PParser<Model: Codable> {
    private var object: Model?
    public init(){}
    public init(object: Model) {
        self.object = object
    }
    public init(data: Data) {
        let decoder = JSONDecoder()
        let object = try? decoder.decode(Model.self, from: data)
        self.object = object
    }
    public convenience init(dict: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            self.init(data: jsonData)
        } catch {
            self.init()
        }
    }
    public func toObject() -> Model? { self.object }
    public func toDict() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(object)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dict
            }
        } catch {
            print("Error while create dictionary: \(error.localizedDescription)")
        }
        return [:]
    }
}

extension PParser where Model: Sequence {
    convenience init(dict: [[String: Any]]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            self.init(data: jsonData)
        } catch {
            self.init()
        }
    }
    public func toDict() -> [[String: Any]] {
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(object)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                return dict
            }
        } catch {
            print("Error while create dictionary: \(error.localizedDescription)")
        }
        return []
    }
}
