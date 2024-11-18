import Foundation

class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "bearerToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bearerToken")
        }
    }
}
