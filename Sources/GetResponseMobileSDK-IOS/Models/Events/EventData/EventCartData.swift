import Foundation

public struct EventCartData: Encodable {
    let price: Double
    let cartId: String?
    let cartUrl: String
    let currency: String
    let products: [OrderProduct]
}
