import Foundation

enum ImagesListServiceError: Error {
    case extraRequest
    case invalidRequest
}

final class ImagesListService {
    
    // MARK: - Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    
    static let shared = ImagesListService()
    private init() {}
    
    private var task: URLSessionTask?
    
    // MARK: - Methods
    
    private func makeImagesListRequest(_ token: String) -> URLRequest? {
        let nextPage = (lastLoadedPage) + 1
        guard
            let url = URL(
                string: "/photos" + "?page=\(nextPage)",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure(">>> [ImagesListService] Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return }
        
        if task != nil {
            print(">>> [ImagesListService] The request is already in progress, no extra request needed")
            completion(.failure(ImagesListServiceError.extraRequest))
            return
        }
        
        guard let request = makeImagesListRequest(token) else {
            print(">>> [ImagesListService] Failed to create the request")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photos):
                var receivedPhotos: [Photo] = []
                for photo in photos {
                    let photo = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.regular,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.likedByUser
                    )
                    receivedPhotos.append(photo)
                }
                self.photos.append(contentsOf: receivedPhotos)
                self.lastLoadedPage += 1
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["updatedPhotos": self.photos]
                    )
                completion(.success(receivedPhotos))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeImagesListLikeRequest(_ token: String, _ photoId: String, _ isLike: Bool) -> URLRequest? {
        guard
            let url = URL(
                string: "/photos" + "/\(photoId)" + "/like",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure(">>> [ImagesListService] Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let token = OAuth2TokenStorage.shared.token
        else { return }
        
        guard let request = makeImagesListLikeRequest(token, photoId, isLike) else {
            print(">>> [ImagesListService] Failed to create the request")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<PhotoWrapper, Error>) in
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]
                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func cleanData() {
        photos = []
        lastLoadedPage = 0
    }
}
