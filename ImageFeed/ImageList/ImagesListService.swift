import Foundation

enum ImagesListServiceError: Error {
    case extraRequest
    case invalidRequest
}

final class ImagesListService {
    
    // MARK: - Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let shared = ImagesListService()
    private init() {}
    
    private var task: URLSessionTask?
    
    // MARK: - Methods
    
//    private func makeImagesListRequest() -> URLRequest? {
//        
//        let nextPage = (lastLoadedPage ?? 0) + 1
//        guard
//            let url = URL(
//                string: "/photos" + "?page=\(nextPage)",
//                relativeTo: Constants.defaultBaseURL
//            )
//        else {
//            assertionFailure(">>> [ImagesListService] Failed to create URL")
//            return nil
//        }
//        let request = URLRequest(url: url)
//        return request
//    }
    
    private func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print(">>> [ImagesListService] The request is already in progress, no extra request needed")
            completion(.failure(ImagesListServiceError.extraRequest))
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard
            let url = URL(
                string: "/photos" + "?page=\(nextPage)",
                relativeTo: Constants.defaultBaseURL
            )
        else {
            assertionFailure(">>> [ImagesListService] Failed to create URL")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        let request = URLRequest(url: url)
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photos):
                self.lastLoadedPage = nextPage
                var receivedPhotos: [Photo] = []
                for photo in photos {
//                    let date = DateFormatter().date(from: photo.createdAt)
                    let photo = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.likedByUser
                    )
                    receivedPhotos.append(photo)
                }
                self.photos.append(contentsOf: receivedPhotos)
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
}
