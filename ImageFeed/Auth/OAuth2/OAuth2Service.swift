import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else { 
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let resultModel):
                completion(.success(resultModel.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
        }
        
//        let task = URLSession.shared.data(for: request) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
//                    completion(.success(response.accessToken))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//            
//            self.task = nil
//            self.lastCode = nil
//        }
        
        self.task = task
        task.resume()
    }
}

