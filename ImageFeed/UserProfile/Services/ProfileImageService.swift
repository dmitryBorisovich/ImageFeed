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
    private(set) var avatarURL: String?
    
    // MARK: - Methods
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return nil }
        
        guard
            let url = URL(
                string: "/users/\(username)"
                + "?client_id=\(Constants.accessKey)",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure(">>> [ProfileImageService] Failed to create URL for username: \(username)")
            return nil
        }

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
        let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userImage):
                let profileImageURL = userImage.profileImage.small
                self.avatarURL = profileImageURL
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
}
