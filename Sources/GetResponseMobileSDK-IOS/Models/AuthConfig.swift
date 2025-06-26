import Foundation

struct AuthConfig: Codable {
    let type: String
    let secret: String?
}
