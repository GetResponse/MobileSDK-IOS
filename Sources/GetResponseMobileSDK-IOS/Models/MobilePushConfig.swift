import Foundation

struct MobilePushConfig: Codable {
    let endpoint: String
    let auth: AuthConfig
    let options: [String]
}
