import Foundation
import UIKit

public class GetResponsePushNotificationService {
    public static let shared = GetResponsePushNotificationService()
    
    private var secret: String?
    private var applicationId: String?
    private var entrypoint: String?
    private var instalationUUID: String!
    
    private let installationUUIDKey = "installationUUID"
    
    private init() {
        if let uuid = UserDefaults.group?.string(forKey: installationUUIDKey) {
            instalationUUID = uuid
        } else {
            instalationUUID = UUID().uuidString
            UserDefaults.group?.set(instalationUUID, forKey: installationUUIDKey)
        }
    }
    
    public func configure(secret: String, applicationId: String, entrypoint: String) {
        self.secret = secret
        self.applicationId = applicationId
        self.entrypoint = entrypoint
    }

    public func consent(lang: String, externalId: String, email: String?, fcmToken: String) async throws {
        checkConfiguration()
        let consent = ConsentModel(lang: lang, externalId: externalId, email: email, fcmToken: fcmToken, platform: "ios")
        guard let consentJson = try? JSONEncoder().encode(consent) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let token = try APIHelpers.shared.createJWTToken(secret: secret!, applicationId: applicationId!, instalationUUID: instalationUUID)
        _ = try await APIHelpers.shared.postData(apiEndpoint: "\(entrypoint!)/consents", jsonData: consentJson, token: token)
    }
    
    public func removeConsent() async throws {
        checkConfiguration()
        let delete = DeleteModel(instalationUUID: instalationUUID)
        guard let deleteJson = try? JSONEncoder().encode(delete) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let token = try APIHelpers.shared.createJWTToken(secret: secret!, applicationId: applicationId!, instalationUUID: instalationUUID)
        _ = try await APIHelpers.shared.deleteData(apiEndpoint: "\(entrypoint!)/consents", jsonData: deleteJson, token: token)
    }
    
    public func handleIncomingNotification(userInfo: [AnyHashable: Any], eventType: EventType) throws -> NotificationHandler? {
        guard let issuer = userInfo["issuer"] as? String, issuer == "getresponse" else {
            print("Not a GetResponse notification")
            return nil
        }
        if let statsUrl = userInfo["stats_url"] as? String {
            APIHelpers.shared.synchonousAction(apiEndpoint: eventType.getEventUrl(url: statsUrl))
        }
        if userInfo["redirect_type"] as? String == "url", let redirectDestination = userInfo["redirect_destination"] as? String,
        let redirectUrl = URL(string: redirectDestination) {
            UIApplication.shared.open(redirectUrl, options: [:], completionHandler: nil)
        }
        return try NotificationHandler(userInfo: userInfo)
    }
    
    private func checkConfiguration() {
        assert(secret != nil && applicationId != nil && entrypoint != nil, "Method configure(secret: String, applicationId: String, entrypoint: String) has to be called first")
    }
    
    public static func handleIncomingNotification(userInfo: [AnyHashable: Any], eventType: EventType) throws -> NotificationHandler?  {
        guard let issuer = userInfo["issuer"] as? String, issuer == "getresponse" else {
            print("Not a GetResponse notification")
            return nil
        }
        if let statsUrl = userInfo["stats_url"] as? String {
            APIHelpers.shared.synchonousAction(apiEndpoint: eventType.getEventUrl(url: statsUrl))
        }
        return try NotificationHandler(userInfo: userInfo)
    }
    
}
