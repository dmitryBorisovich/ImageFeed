import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private func makeUsersProfileRequest(token: String) -> URLRequest? {
        guard
            let url = URL(
                string: "/me"
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if task != nil { 
            completion(.failure(ProfileServiceError.invalidRequest))
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
        
//        let task = URLSession.shared.data(for: request) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    let response = try decoder.decode(ProfileResult.self, from: data)
//                    let userInfo = Profile(
//                        username: response.username,
//                        name: "\(response.firstName) \(response.lastName)",
//                        loginName: "@\(response.username)",
//                        bio: response.bio ?? ""
//                    )
//                    self.profile = userInfo
//                    completion(.success(userInfo))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//            
//            self.task = nil
//        }
        
        self.task = task
        task.resume()
    }
}
