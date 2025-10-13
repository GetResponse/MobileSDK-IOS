import Foundation
import UIKit

public class GetResponsePushNotificationService {
    
    private var secret: String?
    private var applicationId: String?
    private var endpoint: String?
    private var instalationUUID: String?
        
    public func configure(instalationUUID: String, secret: String, applicationId: String, endpoint: String) {
        self.secret = secret
        self.applicationId = applicationId
        self.endpoint = endpoint
        self.instalationUUID = instalationUUID
    }

    public func consent(lang: String, externalId: String, email: String?, fcmToken: String) async throws {
        checkConfiguration()
        let consent = ConsentModel(lang: lang, externalId: externalId, email: email, fcmToken: fcmToken, platform: "ios")
        guard let consentJson = try? JSONEncoder().encode(consent) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let token = try APIHelpers.shared.createJWTToken(secret: secret!, applicationId: applicationId!, installationUUID: instalationUUID!)
        _ = try await APIHelpers.shared.postData(apiEndpoint: "\(endpoint!)/consents", jsonData: consentJson, token: token)
    }
    
    public func removeConsent() async throws {
        checkConfiguration()
        let delete = DeleteModel(instalationUUID: instalationUUID!)
        guard let deleteJson = try? JSONEncoder().encode(delete) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let token = try APIHelpers.shared.createJWTToken(secret: secret!, applicationId: applicationId!, installationUUID: instalationUUID!)
        _ = try await APIHelpers.shared.deleteData(apiEndpoint: "\(endpoint!)/consents", jsonData: deleteJson, token: token)
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
        assert(secret != nil && applicationId != nil && endpoint != nil, "Method configure(secret: String, applicationId: String, entrypoint: String) has to be called first")
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
