# GetResponseMobileSDK-IOS

## Installation

Use swift package menager to add dependecy:
https://github.com/GetResponse/MobileSDK-IOS

## Setup

First, configure SDK:

```swift
GetResponsePushNotificationService.shared.configure(secret: /*secret*/, applicationId:/*applicationId*/, entrypoint: /*entrypoint*/)

```

Send device token:

```swift
await GetResponsePushNotificationService.shared.consent(lang:/*LanguageCode*/, externalId: /*externalId*/, email: /*email*/, fcmToken: notificationManager.token!)

```

Handle notification:

- in app delegate:
```swift
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let notification = try? GetResponsePushNotificationService.shared.handleIncomingNotification(userInfo: userInfo, eventType: EventType.clicked)
        completionHandler()
```

- in NotificationServiceExtension:

```swift
class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            let _ = try? GetResponsePushNotificationService.handleIncomingNotification(userInfo: bestAttemptContent.userInfo, eventType: EventType.showed)
            Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
        }
    }
}
```

To remove token use:

```swift
await GetResponsePushNotificationService.shared.removeConsent()
```


## License
See [LICENSE.TXT](LICENSE.TXT)
