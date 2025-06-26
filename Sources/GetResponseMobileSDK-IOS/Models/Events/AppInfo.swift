import Foundation

public struct AppInfo: Encodable {
    let os: String
    let uuid: String
    let lang: String
    let device = "mobile"
}
