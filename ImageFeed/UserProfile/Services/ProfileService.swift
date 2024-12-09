import Foundation

enum ProfileServiceError: Error {
    case extraRequest
    case invalidRequest
}

final class ProfileService {
    
    // MARK: - Properties
    
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Methods
    
    private func makeUsersProfileRequest(token: String) -> URLRequest? {
        guard
            let url = URL(
                string: "/me"
                + "?client_id=\(Constants.accessKey)",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure(">>> [ProfileService] Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil { 
            completion(.failure(ProfileServiceError.extraRequest))
            return
        }
        
        guard let request = makeUsersProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let userInfo):
                let profile = Profile(
                    username: userInfo.username,
                    name: "\(userInfo.firstName) \(userInfo.lastName)",
                    loginName: "@\(userInfo.username)",
                    bio: userInfo.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
}
