import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    enum OAuth2ServiceConstants {
        static let baseURL = "https://unsplash.com"
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: OAuth2ServiceConstants.baseURL)
        guard 
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&client_secret=\(Constants.secretKey)"
                + "&redirect_uri=\(Constants.redirectURI)"
                + "&code=\(code)"
                + "&grant_type=authorization_code",
                relativeTo: baseURL
            )
        else
            { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(response.accessToken))
                } catch {
                    print("Failed to parse data: \(error.localizedDescription)")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

