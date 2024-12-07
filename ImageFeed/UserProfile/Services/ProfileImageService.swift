import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    private func makeProfileImageRequest(token: String) -> URLRequest? {
        guard let profile = ProfileService.shared.profile else { return nil }
        
        guard
            let url = URL(
                string: "/users/\(profile.username)"
                + "?client_id=\(Constants.accessKey)",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure("Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": avatarURL as Any]
            )
        
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let token = OAuth2TokenStorage.shared.token,
              let request = makeProfileImageRequest(token: token)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userImage):
                self.avatarURL = userImage.small
                completion(.success(userImage.small))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
}
