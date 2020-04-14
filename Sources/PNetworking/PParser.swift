//
//  PParser.swift
//
//  Created by Phat Pham on 12/15/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation

public protocol DataConvertable {
    associatedtype Object: Codable
}

extension DataConvertable {
    func objectFrom(data: Data) -> Object? {
        return try? JSONDecoder().decode(Object.self, from: data)
    }
    
    func dataFrom(object: Object) -> Data? {
        return try? JSONEncoder().encode(object)
    }
    
    func objectFrom(dict: [String: Any]) -> Object? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return nil
        }
        return objectFrom(data: data)
    }
    func dictFrom(object: Object) -> [String: Any]? {
        guard let data = dataFrom(object: object) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]
    }
}

extension DataConvertable where Object: Sequence {
    func dictFrom(object: Object) -> [[String: Any]]? {
        guard let data = dataFrom(object: object) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [[String: Any]]
    }
}

open class PParser<Model: Codable>: DataConvertable {
    public typealias Object = Model
    
    private var object: Model?
    public init(){}
    public init(object: Model) {
        self.object = object
    }
    public init(data: Data) {
        let object = objectFrom(data: data)
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
    public func toDict() -> [String: Any]? {
        guard let object = object else { return nil }
        let dict = dictFrom(object: object)
        return dict
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
    public func toDict() -> [[String: Any]]? {
        guard let object = object else { return nil}
        let dict = dictFrom(object: object)
        return dict
    }
}
