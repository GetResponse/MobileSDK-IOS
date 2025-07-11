//
//  File.swift
//  
//
//  Created by Jacek Stasiński on 06/03/2024.
//

import Foundation

public enum NotificationHandlerError: Error {
    case invalidPayload
}

public enum ActionType {
    case openApp
    case openURL
    case deeplink
}

fileprivate let keysToFilterCustomData = ["aps", "issuer", "redirect_type", "redirect_destination", "stats_url", "google.c.fid", "fcm_options", "gcm.message_id", "google.c.a.e", "google.c.sender.id", "actions"]

public struct NotificationHandler {
    public let title: String
    public let body: String
    public let imageURL: String?
    public let action: ActionType
    public let redirectionURL: String?
    public let deeplinkPath: String?
    public let customData: [String: String]
    public let actions: [Action]
    
    
    internal init(userInfo: [AnyHashable: Any]) throws {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any], let redirctType = userInfo["redirect_type"] as? String,  let alert = aps["alert"] as? [AnyHashable: Any], let title = alert["title"] as? String, let body = alert["body"] as? String else {
            throw NotificationHandlerError.invalidPayload
        }
        if let fcmOptions = userInfo["fcm_options"] as? [AnyHashable: Any], let imageURL = fcmOptions["image"] as? String {
            self.imageURL = imageURL
        } else {
            self.imageURL = nil
        }
        if redirctType == "application" {
            action = ActionType.openApp
            self.redirectionURL = nil
            self.deeplinkPath = nil
        } else if redirctType == "deep_link" {
            guard let deeplinkPath = userInfo["redirect_destination"] as? String else {
                throw NotificationHandlerError.invalidPayload
            }
            self.action = ActionType.deeplink
            self.deeplinkPath = deeplinkPath
            self.redirectionURL = nil
            
        } else {
            guard let redirectionURL = userInfo["redirect_destination"] as? String else {
                throw NotificationHandlerError.invalidPayload
            }
            self.action = ActionType.openURL
            self.redirectionURL = redirectionURL
            self.deeplinkPath = nil
        }
        self.title = title
        self.body = body
        
        if let actionsJsonString = userInfo["actions"] as? String,
           let actionsData = try? JSONSerialization.jsonObject(with: actionsJsonString.data(using: .utf8) ?? Data()) as? [[AnyHashable: Any]] {
            self.actions = actionsData.compactMap { actionData in
                try? Action(data: actionData)
            }
        } else {
            self.actions = []
        }
        var data = [String: String]()
        var filteredKeys = [String]()
        for key in userInfo.keys {
            if(!keysToFilterCustomData.contains(key as! String)) {
                filteredKeys.append(key as! String)
            }
        }
        filteredKeys.forEach { key in
            data[key as String] = userInfo[key] as? String
        }
        self.customData = data
    }
}

public class Action {
    public let identifier: String
    public let redirectDestination: String?
    public let redirectType: ActionType
    public let text: String
    
    public init(data: [AnyHashable: Any]) throws {
        guard let identifier = data["identifier"] as? String,
              let redirectTypeString = data["redirect_type"] as? String,
              let text = data["text"] as? String else {
            throw NotificationHandlerError.invalidPayload
        }
        
        self.identifier = identifier
        self.redirectDestination = data["redirect_destination"] as? String
        
        switch redirectTypeString {
        case "application":
            self.redirectType = .openApp
        case "deep_link":
            self.redirectType = .deeplink
        default:
            self.redirectType = .openURL
        }
        
        self.text = text
    }
}
