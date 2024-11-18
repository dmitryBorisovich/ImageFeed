import Foundation

class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    enum OAuth2ServiceConstants {
        static let baseURL = "https://unsplash.com"
    }
        
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.baseURL) else {
            print(">>> Components initialization failed")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.accessScope),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print(">>> URL creation failed")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String) {
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = response.accessToken
                    
                } catch {
                    print("Failed to parse: \(error.localizedDescription)")
                }
            case .failure(_):
                // TODO: process code
                print("")
            }
        }
        
        task.resume()
    }
}
