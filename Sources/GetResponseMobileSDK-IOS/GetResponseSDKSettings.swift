public struct GetResponseSDKSettings {
    let enablePushNotifications: Bool
    let enableWebEvents: Bool
    
    public init(enablePushNotifications: Bool = true, enableWebEvents: Bool = true) {
        self.enablePushNotifications = enablePushNotifications
        self.enableWebEvents = enableWebEvents
    }
}
