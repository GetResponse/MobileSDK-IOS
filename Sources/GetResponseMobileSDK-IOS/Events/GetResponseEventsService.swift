import Foundation

public class GetResponseEventsService {
    
    private var shop: Shop?
    private var endpoint: String?
    private var instalationUUID: String?
    private var user: User?
    
    private var events: [EventPayload] = []
    
    public func configure(instalationUUID: String, shop: Shop, endpoint: String, user: User) {
        self.instalationUUID = instalationUUID
        self.shop = shop
        self.endpoint = endpoint
        self.user = user
    }
    
    private func appInfo(lang: String) -> AppInfo {
        return AppInfo(
            os: "iOS",
            uuid: instalationUUID!,
            lang: lang)
    }
    
    private var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "y-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
    
    private func addItemEvent(version: String, eventName: EventName, language: String, product: Product, categories: [Category]) {
        let event = EventPayload(
            occurredOn: dateformatter.string(from: Date()),
            time: nil,
            app: appInfo(lang: language),
            userUUID: user!.uuid,
            visitor: Visitor(
                installationUUID: instalationUUID!,
                ip: nil
            ),
            event: Event(
                version: version,
                name: eventName,
                data: .item(EventItemData(
                    shop: shop,
                    product: product,
                    categories: categories
                ))
            ),
            tags: [],
            geo: nil
        )
        
        events.append(event)
        print("Event added: \(eventName.rawValue)")
    }
    
    public func addViewItemEvent(
        language: String, product: Product, categories: [Category]) {
            addItemEvent(version: "1.0", eventName: EventName.viewItem, language: language, product: product, categories: categories);
        }
    
    public func  addWishListItemEvent(
        language: String, product: Product, categories: [Category]) {
            addItemEvent(version: "1.0", eventName: EventName.wishlitItem, language: language, product: product, categories: categories);
        }
    
    public func  addLikeItemEvent(
        language: String, product: Product, categories: [Category]) {
            addItemEvent(version: "1.0", eventName: EventName.likeItem, language: language, product: product, categories: categories);
        }
    
    public func  addUnlikeItemEvent(
        language: String, product: Product, categories: [Category]) {
            addItemEvent(version: "1.0", eventName: EventName.unlikeItem, language: language, product: product, categories: categories);
        }
    
    public func addViewCategoryEvent(language: String, categoryId: String, categoryName: String?) {
        let event = EventPayload(
            occurredOn: dateformatter.string(from: Date()),
            time: nil,
            app: appInfo(lang: language),
            userUUID: user!.uuid,
            visitor: Visitor(
                installationUUID: instalationUUID!,
                ip: nil
            ),
            event: Event(
                version: "1.0",
                name: EventName.viewCategory,
                data: .category(EventCategoryData(
                    shop: shop,
                    id: categoryId,
                    name: categoryName
                ))
            ),
            tags: [],
            geo: nil
        )
        
        events.append(event)
        print("Event added: \(EventName.viewCategory.rawValue)")
    }
    
    private func addOrderEvent(
        version: String,
        eventName: EventName,
        language: String,
        cartId: String?,
        orderId: String,
        currency: String,
        price: Double,
        orderProducts: [OrderProduct]
    ) {
        let event = EventPayload(
            occurredOn: dateformatter.string(from: Date()),
            time: nil,
            app: appInfo(lang: language),
            userUUID: user!.uuid,
            visitor: Visitor(
                installationUUID: instalationUUID!,
                ip: nil
            ),
            event: Event(
                version: version,
                name: eventName,
                data: .order(EventOrderData(
                    shop: shop,
                    price: price,
                    cartId: cartId,
                    orderId: orderId,
                    currency: currency,
                    products: orderProducts
                ))
            ),
            tags: [],
            geo: nil
        )
        
        events.append(event)
        print("Event added: \(eventName.rawValue)")
    }
    
    public func addOrderPlacedEvent(
        language: String,
        cartId: String?,
        orderId: String,
        currency: String,
        price: Double,
        orderProducts: [OrderProduct]
    ) {
        addOrderEvent(
            version: "1.0",
            eventName: EventName.orderPlaced,
            language: language,
            cartId: cartId,
            orderId: orderId,
            currency: currency,
            price: price,
            orderProducts: orderProducts)
    }
    
    public func addOrderPaidEvent(
        language: String,
        cartId: String?,
        orderId: String,
        currency: String,
        price: Double,
        orderProducts: [OrderProduct]
    ) {
        addOrderEvent(
            version: "1.0",
            eventName: EventName.orderPaid,
            language: language,
            cartId: cartId,
            orderId: orderId,
            currency: currency,
            price: price,
            orderProducts: orderProducts)
    }
    
    public func addCartEvent(
        language: String,
        cartId: String?,
        cartUrl: String,
        currency: String,
        price: Double,
        orderProducts: [OrderProduct]
    ) {
        let event = EventPayload(
            occurredOn: dateformatter.string(from: Date()),
            time: nil,
            app: appInfo(lang: language),
            userUUID: user!.uuid,
            visitor: Visitor(
                installationUUID: instalationUUID!,
                ip: nil
            ),
            event: Event(
                version: "1.0",
                name: EventName.cartUpdate,
                data: .cart(EventCartData(
                    price: price,
                    cartId: cartId,
                    cartUrl: cartUrl,
                    currency: currency,
                    products: orderProducts
                ))
            ),
            tags: [],
            geo: nil
        )
        
        events.append(event)
        print("Event added: \(EventName.cartUpdate.rawValue)")
    }
    
    public func sendEvents() async throws {
        
        let eventsData = try JSONEncoder().encode(events)
        
        let result = try await APIHelpers.shared.postData(apiEndpoint: endpoint!, jsonData: eventsData, token: nil)
        
        if result.1 >= 400 {
            print("Error while sending events")
            throw NetworkError.httpError(statusCode: result.1)
        } else {
            print("\(events.count) Event('s) sent successfully")
            events.removeAll()
        }
    }
}

enum NetworkError: Error {
    case httpError(statusCode: Int)
}
