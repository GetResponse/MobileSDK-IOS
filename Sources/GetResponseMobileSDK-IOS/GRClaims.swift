import Foundation
import SwiftJWT

struct GRClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: String
}
