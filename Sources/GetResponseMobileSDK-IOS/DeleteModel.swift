import Foundation

public struct DeleteModel: Codable {
    
    let instalationUUID: String
    
    enum CodingKeys: String, CodingKey {
        case instalationUUID = "installation_uuid"
    }
}
