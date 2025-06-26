import Foundation

public struct EventOrderData: Encodable {
    let shop: Shop?
    let price: Double
    let cartId: String?
    let orderId: String
    let currency: String
    let products: [OrderProduct]
}

public struct OrderProduct: Encodable {
    let product: Product
    let categories: [Category]?
    let quantity: Int
    
    public init(product: Product, categories: [Category]?, quantity: Int) {
        self.product = product
        self.categories = categories
        self.quantity = quantity
    }
}
