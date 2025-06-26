import Foundation

public struct Category: Encodable {
    let id: String
    let name: String?
    
    public init(id: String, name: String?) {
        self.id = id
        self.name = name
    }
}
