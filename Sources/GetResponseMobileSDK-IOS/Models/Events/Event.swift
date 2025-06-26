import Foundation

public struct Event: Encodable {
    let version: String
    let name: EventName
    let data: EventDataType
    
    
    enum CodingKeys: String, CodingKey {
        case version, name, data
    }
    
    public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(name, forKey: .name)
            
        switch data {
            case .item(let data):
                try container.encode(data, forKey: .data)
            case .category(let data):
                try container.encode(data, forKey: .data)
            case .order(let data):
                try container.encode(data, forKey: .data)
            case .cart(let data):
                try container.encode(data, forKey: .data)
        }
    }
}


public enum EventName: String, Encodable {
    case viewItem = "view_item"
    case viewCategory = "view_category"
    case wishlitItem = "wishlist_item"
    case likeItem = "like_item"
    case unlikeItem = "unlike_item"
    case orderPlaced = "order_placed"
    case orderPaid = "order_paid"
    case cartUpdate = "cart_update"
}


public enum EventDataType {
    case item(EventItemData)
    case category(EventCategoryData)
    case order(EventOrderData)
    case cart(EventCartData)
}
