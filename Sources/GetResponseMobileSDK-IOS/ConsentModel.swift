import Foundation

public struct ConsentModel: Codable {
    let lang: String
    let externalId: String
    let email: String?
    let fcmToken: String
    let platform: String
    
    enum CodingKeys: String, CodingKey {
        case lang
        case externalId = "external_id"
        case email
        case fcmToken = "fcm_token"
        case platform
    }
}

public enum EventType: String {
    case closed = "cs"
    case showed = "sh"
    case clicked = "cl"
    
    func getEventUrl(url: String) -> String {
        return "\(url)act=\(rawValue)"
    }
}
