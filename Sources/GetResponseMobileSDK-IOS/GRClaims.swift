import Foundation
import SwiftJWT

struct GRClaims: Claims {
    let iss: String
    let iat: Int
    let exp: Int
    let aud: String
}
