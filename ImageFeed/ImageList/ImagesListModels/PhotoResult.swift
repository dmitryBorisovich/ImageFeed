import Foundation

struct PhotoWrapper: Decodable {
    let photo: PhotoResult
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Double
    let height: Double
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}
