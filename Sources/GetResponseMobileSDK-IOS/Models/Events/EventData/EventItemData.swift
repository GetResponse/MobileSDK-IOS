import Foundation

public struct EventItemData: Encodable {
    let shop: Shop?
    let product: Product
    let categories: [Category]?
}
