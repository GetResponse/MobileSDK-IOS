import Foundation

public struct Product: Encodable {
    let id: String
    let sku: String?
    let name: String?
    let vendor: String?
    let price: Double?
    let currency: String?
    
    public init(id: String, sku: String?, name: String?, vendor: String?, price: Double?, currency: String?) {
        self.id = id
        self.sku = sku
        self.name = name
        self.vendor = vendor
        self.price = price
        self.currency = currency
    }
}
