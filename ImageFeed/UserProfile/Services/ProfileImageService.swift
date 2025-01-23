import Foundation

enum ProfileImageServiceError: Error {
    case extraRequest
    case invalidRequest
}

final class ProfileImageService {
    
    // MARK: - Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private var task: URLSessionTask?
    var avatarURL: String?
    
    // MARK: - Methods
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return nil }
        
        guard var urlComponents = URLComponents(string: Constants.defaultBaseURL + "users/\(username)") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        
        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print(">>> [ProfileImageService] The request is already in progress, no extra request needed")
            completion(.failure(ProfileImageServiceError.extraRequest))
            return
        }
        
        guard
            let request = makeProfileImageRequest(username: username)
        else {
            print(">>> [ProfileImageService] Failed to create the request")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userImage):
                let profileImageURL = userImage.profileImage.small
                avatarURL = profileImageURL
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                completion(.success(userImage.profileImage.small))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func cleanData() {
        avatarURL = nil
    }
}
