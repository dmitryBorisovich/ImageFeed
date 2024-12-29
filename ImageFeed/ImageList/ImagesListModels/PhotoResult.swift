import Foundation

//struct Photos: Decodable {
//    let photos: [PhotoResult]
//}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String /*Date?*/
    let width: Double
    let height: Double
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}
