//
//  PNetworking.swift
//
//  Created by Phat Pham on 12/15/19.
//  Copyright © 2019 phthphat. All rights reserved.
//

import Foundation
#if !os(macOS)
    import UIKit
#endif

public protocol PNetworking {
    var baseUrl: String { get }
    func requestNormalData(endPoint: EndPoint, handle: @escaping (Result<Data, NetworkError>) -> Void )

    #if !os(macOS)
    func requestFormData(endPoint: EndPoint, handle: @escaping (Result<Data, NetworkError>) -> Void )
    #endif
}
//MARK: Helper function
extension PNetworking {
    private func convertToUrlComponent(url: String) -> URLComponents? {
        guard let url = URL(string: url) else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
    
    private func makeRequest(request: URLRequest, endPoint: EndPoint, handle: @escaping (Result<Data, NetworkError>) -> Void) {
        let session = URLSession.shared
        printApiLog(endPoint: endPoint, processAt: .requestStart)
        
        session.dataTask(with: request) { (_data, res, error) in
            self.printApiLog(endPoint: endPoint, processAt: .respondReceive)
            if let error = error {
                DispatchQueue.main.async {
                    handle(.failure(.network(msg: error.localizedDescription)))
                }
                self.printApiLog(endPoint: endPoint, processAt: .end)
                return
            }
            
            guard let data = _data else {
                handle(.failure(.network(msg: "No data response")))
                self.printApiLog(endPoint: endPoint, processAt: .end)
                return
            }
            
            DispatchQueue.main.async {
                self.printJsonData(data)
                handle(.success(data))
                self.printApiLog(endPoint: endPoint, processAt: .end)
            }
        }.resume()
    }
}

//MARK: Print log helper
extension PNetworking {
    
    private func printApiLog(endPoint: EndPoint, processAt: ProcessPosition) {
        switch processAt {
        case .requestStart:
            print("---- Request \(endPoint.httpMethod) on \(endPoint.path) ----")
            print("Header:", endPoint.headers ?? "empty")
            print("Param:", endPoint.parameters)
        case .respondReceive:
            print("---- Response \(endPoint.httpMethod) on \(endPoint.path) ----")
        case .errorOccur(let err):
            print("Error: ", err.localizedDescription)
        case .end:
            print("---- Finish request \(endPoint.httpMethod) on \(endPoint.path) ----")
        }
    }
    
    private func printJsonData(_ data: Data) {
        print("Json:", (try? JSONSerialization.jsonObject(with: data, options: [])) ?? "Unknown" )
    }
}
private enum ProcessPosition {
    case errorOccur(error: Error)
    case requestStart
    case respondReceive
    case end
}

//MARK: Work with normal request
extension PNetworking {
    private func generateRequest(from endPoint: EndPoint) throws -> URLRequest {
        let fullUrl = baseUrl + endPoint.path
        var urlComp = convertToUrlComponent(url: fullUrl)
        var request: URLRequest?
        
        switch endPoint.httpMethod {
        case .get:
            let queryItems = endPoint.parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
            urlComp?.queryItems = queryItems

            guard let urlToCall = urlComp?.url else {
                throw NetworkError.badUrl
            }
            request = URLRequest(url: urlToCall)
        default:
            
            guard let urlToCall = urlComp?.url else {
                throw NetworkError.badUrl
            }
            request = URLRequest(url: urlToCall)
            request?.httpBody = try? JSONSerialization.data(withJSONObject: endPoint.parameters, options: .prettyPrinted)
        }
        
        request?.httpMethod = endPoint.httpMethod.rawValue
        request?.allHTTPHeaderFields = endPoint.headers
        request?.addValue("Application/json", forHTTPHeaderField: "Content-type")
        return request!
    }
    
    public func requestNormalData(endPoint: EndPoint, handle: @escaping (Result<Data, NetworkError>) -> Void ){
        do {
            let request = try generateRequest(from: endPoint)
            makeRequest(request: request, endPoint: endPoint, handle: handle)
        } catch {
            guard let err = error as? NetworkError else {
                handle(.failure(.custom(msg: error.localizedDescription)))
                return
            }
            handle(.failure(err))
        }
    }
}

//MARK: Work with form data, multipart
#if !os(macOS)
extension PNetworking {
    private func generateFormDataRequest(from endPoint: EndPoint) throws -> URLRequest {
        
        let fullUrl = baseUrl + endPoint.path
        guard let url = URL(string: fullUrl) else {
            throw NetworkError.badUrl
        }
        var request = URLRequest(url: url)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.httpMethod = endPoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        let httpBody = endPoint.parameters.reduce(NSMutableData()) { _preVal, param in
            let preVal = _preVal
            switch param.value {
            case let img as UIImage:
                preVal.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                preVal.append("Content-Disposition: form-data; name=\"\(param.key)\"; filename=\"\(Date().timeIntervalSince1970).jpg\"\r\n".data(using: .utf8)!)
                preVal.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                preVal.append(img.jpegData(compressionQuality: 1)!)
            default:
                preVal.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                preVal.append("Content-Disposition: form-data; name=\"\(param.key)\"\r\n\r\n".data(using: .utf8)!)
                preVal.append("\(param.value)".data(using: .utf8)!)
            }
            return preVal
        }
        
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody as Data
        return request
    }
    public func requestFormData(endPoint: EndPoint, handle: @escaping (Result<Data, NetworkError>) -> Void ) {
        do {
            let request = try generateFormDataRequest(from: endPoint)
            makeRequest(request: request, endPoint: endPoint, handle: handle)
        } catch {
            guard let err = error as? NetworkError else {
                handle(.failure(.custom(msg: error.localizedDescription)))
                return
            }
            handle(.failure(err))
        }
    }
}
#endif
