import Foundation

enum Constants {
    static let accessKey = "iNaFNtuyZH1P8xOknycZ8J4vr3qqqv-JwR1RTR2sD4Q"
    static let secretKey = "EPIoztGEuBVVrLT63b5H666FfPZFdUobWlaHsAJzw6g"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = "https://api.unsplash.com/"
    static let codePath = "/oauth/authorize/native"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: String
    let codePath: String
    let unsplashAuthorizeURLString: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURL: String,
        codePath: String,
        unsplashAuthorizeURLString: String
    ){
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.codePath = codePath
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            codePath: Constants.codePath,
            unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
