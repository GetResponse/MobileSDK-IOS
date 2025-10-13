import Foundation
import UIKit

public class GetResponseSDK {
    public static let shared = GetResponseSDK()
    private let notifications = GetResponsePushNotificationService()
    private let events = GetResponseEventsService()
    private var secret: String?
    private var applicationId: String?
    private var entrypoint: String?
    private var instalationUUID: String!
    private var settings: GetResponseSDKSettings!
    private let installationUUIDKey = "installationUUID"
    
    private init() {
        if let uuid = UserDefaults.group?.string(forKey: installationUUIDKey) {
            instalationUUID = uuid
        } else {
            instalationUUID = UUID().uuidString
            UserDefaults.group?.set(instalationUUID, forKey: installationUUIDKey)
        }
    }
    
    public func configure(secret: String, applicationId: String, entrypoint: String, settings: GetResponseSDKSettings = GetResponseSDKSettings()) async throws {
        self.secret = secret
        self.applicationId = applicationId
        self.entrypoint = entrypoint
        self.settings = settings
        let presets = try await initSDK()
        guard let presets = presets else {
            return
        }
        if settings.enablePushNotifications {
            print(presets.webevents)
            if presets.notificationsAvailable  {
                notifications.configure(instalationUUID: instalationUUID, secret: secret, applicationId: applicationId, endpoint: presets.mobilepush!.endpoint)
            } else {
                print("Push notifications are not available")
            }
        }
        if settings.enableWebEvents {
            if presets.webEventsAvailable  {
                events.configure(instalationUUID: instalationUUID, shop: presets.webevents!.options.shop!, endpoint: presets.webevents!.endpoint, user: presets.webevents!.options.user)
            } else {
                print("Events are not available")
            }
        }
    }
    
    public var notificationsService: GetResponsePushNotificationService {
        checkConfiguration()
        if settings!.enablePushNotifications {
            return notifications
        } else {
            fatalError("Push notifications are disabled")
        }
    }
    
    public var eventsService: GetResponseEventsService {
        checkConfiguration()
        if settings!.enableWebEvents {
            return events
        } else {
            fatalError("Push notifications are disabled")
        }
    }
    
    private func checkConfiguration() {
        assert(secret != nil && applicationId != nil && entrypoint != nil, "Method configure(secret: String, applicationId: String, entrypoint: String) has to be called first")
    }
    
    
    private func initSDK() async throws -> PresetsModel? {
        let token = try APIHelpers.shared.createJWTToken(secret: secret!, applicationId: applicationId!, installationUUID: instalationUUID)
        print("token: \(token)")
        let result = try await APIHelpers.shared.getData(apiEndpoint: "\(entrypoint!)/presets", jsonData: nil, token: token)
        guard let result = result.0 else {
            return nil
        }
        return try JSONDecoder().decode(PresetsModel.self, from: result)
    }
}
