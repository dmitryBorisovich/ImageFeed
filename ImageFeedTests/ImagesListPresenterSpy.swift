import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadPhotosPage() {}
    
    func photosCount() -> Int { 0 }
    
    func getThumbImageUrl(for indexPath: IndexPath) -> URL? { nil }
    
    func getLargeImageUrl(for indexPath: IndexPath) -> URL? { nil }
    
    func getSizeOfImage(for indexPath: IndexPath) -> CGSize { CGSize() }
    
    func getPhotoCreationDate(for indexPath: IndexPath) -> String? { nil }
    
    func isPhotoLiked(with indexPath: IndexPath) -> Bool { false }
    
    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, any Error>) -> Void) {}
}

