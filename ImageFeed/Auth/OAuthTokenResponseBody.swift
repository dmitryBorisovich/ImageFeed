import Foundation

enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}
