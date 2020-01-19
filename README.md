# PNetworking

- Use `PNetworking` (based on URLSession) instead of Alamofire 
- Use `PParser` (based on Codable) instead of ObjectMapper

**Disclaimer: I use this package for my personal project. I don't recommend you use it in big, massive project because the package is still young. But if you love, you can be a distributor with me :D**

## PNetworking (work with API)
```swift
let network = PNetworking(baseUrl: "https://sample.com")

network.request(endPoint: SampleEndPoint.logIn(username: "abc", password: "123")) { [weak self] result in
    switch result {
    case .success(let data):
        break
    case .failure(let err):
        break
    }
}
enum SampleEndPoint {
    case logIn(username: String, password: String)
}
extension SampleEndPoint: EndPoint {
    var path: String {
        switch self {
        case .logIn:
            return "/auth"
        default:
            return ""
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .logIn:
            return .post
        default:
            return .get
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .logIn(let username, let password):
            return ["username": username, "password": password]
        default:
            return [:]
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
```
It's looked verbose with one request, but it can be your codebase with the more case in a endpoint

## PParser
Parsing data between Dictionary, Codable Object and Data

```swift

class User: Codable {
    var id: Int?
    var username: String?
}

let userData: Data
let userParser = PParser<User>(data: userData)

var user: User = PParser.toObject()!
var userDict: [String: Any] = userParser.toDict()!
```

## Contributor
- Phat Pham: [gitlab](https://gitlab.com/phthphat), [facebook](https://www.facebook.com/phthphat)
