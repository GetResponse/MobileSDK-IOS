import Foundation

public struct Visitor: Encodable {
    let installationUUID: String
    let ip: String?
    
    enum CodingKeys: String, CodingKey {
        case installationUUID = "installation_uuid"
        case ip
    }
}
