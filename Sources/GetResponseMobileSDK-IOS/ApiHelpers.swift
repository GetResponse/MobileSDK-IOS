import Foundation
import Network
import SwiftJWT

class APIHelpers {
    
    static let shared = APIHelpers()
    
    private init() {
    }
    
    private func baseApiCall(apiEndpoint: String, jsonData: Data?, httpMethod: String, token: String?) async throws -> (Data?, Int) {
        let url = URL(string: apiEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("1.1", forHTTPHeaderField: "X-Sdk-Version")
        request.setValue("IOS", forHTTPHeaderField: "X-Sdk-Platform")
        if (token != nil) {
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        }
        if (jsonData != nil) {
            request.httpBody = jsonData
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            print("server error")
            return (nil, 500)
        }
        
        switch response.statusCode {
        case 400 ..< 600: print("Response error: \(response.statusCode), message: \(response.description), response: \(response)")
        default: print("Response status code: \(response.statusCode)")
        }
        return (data, response.statusCode)
    }
    
    func synchonousAction(apiEndpoint: String) {
        let url = URL(string: apiEndpoint)
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, let response = response as? HTTPURLResponse, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            switch response.statusCode {
            case 400 ..< 600: print("Response error: \(response.statusCode), message: \(response.description)")
            default: print("Response status code: \(response.statusCode)")
            }
        }
        task.resume()
    }
    
    
    func createJWTToken(secret: String, applicationId: String, installationUUID: String) throws -> String{
        let startDate = Date().addingTimeInterval(-1)
        let expireDate = Date().addingTimeInterval(19)
        let claims = GRClaims(iss: applicationId, iat: Int(startDate.timeIntervalSince1970), exp: Int(expireDate.timeIntervalSince1970), aud: installationUUID)
        var jwt = JWT(claims: claims)
        let jwtSigner = JWTSigner.hs256(key: secret.data(using: .utf8)!)
        return try jwt.sign(using: jwtSigner)
    }
    
    func postData(apiEndpoint: String, jsonData: Data, token: String?) async throws -> (Data?, Int) {
        return try await baseApiCall(apiEndpoint: apiEndpoint, jsonData: jsonData, httpMethod: "POST", token: token)
    }
    
    func getData(apiEndpoint: String, jsonData: Data?, token: String?) async throws -> (Data?, Int) {
        return try await baseApiCall(apiEndpoint: apiEndpoint, jsonData: jsonData, httpMethod: "GET", token: token)
    }
    
    func deleteData(apiEndpoint: String, jsonData: Data?, token: String?) async throws -> (Data?, Int) {
        return try await baseApiCall(apiEndpoint: apiEndpoint, jsonData: jsonData, httpMethod: "DELETE", token: token)
    }
}
