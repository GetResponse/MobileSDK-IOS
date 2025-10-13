import Foundation

public struct PresetsModel: Codable {
    let mobilepush: MobilePushConfig?
    let webevents: WebEventsConfig?
    
    var notificationsAvailable: Bool {
        return mobilepush != nil
    }
    
    var webEventsAvailable: Bool {
        return webevents != nil
    }
        
}
