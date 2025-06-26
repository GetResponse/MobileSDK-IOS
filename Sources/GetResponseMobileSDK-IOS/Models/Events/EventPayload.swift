import Foundation

public struct EventPayload: Encodable {
    let version: String = "1.0"
    let occurredOn: String
    let time: Int?
    let app: AppInfo
    let userUUID: String
    let visitor: Visitor
    let channel: Channel = .mobile
    let path: String = ""
    let event: Event
    let tags: [String]?
    let geo: GeoLocation?
    
    enum CodingKeys: String, CodingKey {
        case version
        case occurredOn = "occurred_on"
        case time
        case app
        case visitor
        case channel
        case userUUID = "user_uuid"
        case path
        case event
        case tags
        case geo
    }
}

enum Channel: String, Codable {
    case web
    case mobile
    case api
}
