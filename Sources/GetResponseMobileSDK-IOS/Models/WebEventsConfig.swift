import Foundation

struct WebEventsConfig: Codable {
    let endpoint: String
    let auth: AuthConfig
    let options: EndpointOptions
}

struct EndpointOptions: Codable {
    let shop: Shop?
    let user: User
}


public struct User: Codable {
    let uuid: String
}
