//
//  Networking.swift
//
//  Created by Phat Pham on 12/15/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation
#if !os(macOS)
    import UIKit
#endif

public protocol PNetworking {
    func request(endPoint: EndPoint, handle: @escaping (Result<Data, Error>) -> Void )
    func requestFormData(endPoint: EndPoint, handle: @escaping (Result<Data, Error>) -> Void )
}

open class PNetwork: PNetworking {
    
    
    public var baseUrl: String
    public init(baseUrl: String){
        self.baseUrl = baseUrl
    }
    private var request: URLRequest?
    
    private func requestData(endPoint: EndPoint, handle: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared
        print("---- Request \(endPoint.httpMethod) on \(endPoint.path) ----")
        print("Header:", endPoint.headers ?? "empty")
        print("Param:", endPoint.parameters)
        guard let request = self.request else { return }
        session.dataTask(with: request) { (_data, res, error) in
            print("---- Response \(endPoint.httpMethod) on \(endPoint.path) ----")
            if let error = error {
                DispatchQueue.main.async {
                    handle(.failure(error))
                }
                print("Error: ", error.localizedDescription)
                return
            }
            guard let data = _data else { return }
            DispatchQueue.main.async {
                print("Json:", (try? JSONSerialization.jsonObject(with: data, options: [])) ?? "Unknown" )
                handle(.success(data))
            }
        }.resume()
    }
}

//MARK: Work with normal request
extension PNetwork {
    private func setUpRequest(endPoint: EndPoint){
        let fullUrl = baseUrl + endPoint.path
        var urlComp = URLComponents(url: URL(string: fullUrl)!, resolvingAgainstBaseURL: true)
        if endPoint.httpMethod == .get {
            var queryItems: [URLQueryItem] = []
            endPoint.parameters.forEach { (arg) in
                
                let (key, value) = arg
                queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }
            urlComp?.queryItems = queryItems
        }
        guard let urlToCall = urlComp?.url else { return }
        request = URLRequest(url: urlToCall)
        request?.httpMethod = endPoint.httpMethod.rawValue
        request?.allHTTPHeaderFields = endPoint.headers
        request?.addValue("Application/json", forHTTPHeaderField: "Content-type")
        if let data = try? JSONSerialization.data(withJSONObject: endPoint.parameters, options: []), endPoint.httpMethod != .get {
            request?.httpBody = data
        }
    }
    
    public func request(endPoint: EndPoint, handle: @escaping (Result<Data, Error>) -> Void ){
        setUpRequest(endPoint: endPoint)
        requestData(endPoint: endPoint, handle: handle)
    }
}

//MARK: Work with form data, multipart
extension PNetwork {
    private func setUpFormDataRequest(endPoint: EndPoint){
        
        let fullUrl = baseUrl + endPoint.path
        let boundary = "Boundary-\(UUID().uuidString)"
        
        self.request = URLRequest(url: URL(string: fullUrl)!)
        request?.httpMethod = endPoint.httpMethod.rawValue
        request?.allHTTPHeaderFields = endPoint.headers
        request?.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        request?.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        let httpBody = NSMutableData()
        
        endPoint.parameters.forEach { (key, value) in
            switch value {
            case let img as UIImage:
                httpBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(Date().timeIntervalSince1970).jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(img.jpegData(compressionQuality: 1)!)
            default:
                httpBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                httpBody.append("\(value)".data(using: .utf8)!)
            }
        }
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request?.httpBody = httpBody as Data
    }
    public func requestFormData(endPoint: EndPoint, handle: @escaping (Result<Data, Error>) -> Void) {
        setUpFormDataRequest(endPoint: endPoint)
        requestData(endPoint: endPoint, handle: handle)
    }
}
