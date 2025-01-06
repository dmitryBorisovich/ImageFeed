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
        guard var urlComponents = URLComponents(string: Constants.defaultBaseURL + "me") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        
        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print(">>> [ProfileService] The request is already in progress, no extra request needed")
            completion(.failure(ProfileServiceError.extraRequest))
            return
        }
        
        guard let request = makeUsersProfileRequest(token: token) else {
            print(">>> [ProfileService] Failed to create the request")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userInfo):
                let profile = Profile(
                    username: userInfo.username,
                    name: "\(userInfo.firstName) \(userInfo.lastName ?? "")",
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
    
    func cleanData() {
        profile = nil
    }
}
