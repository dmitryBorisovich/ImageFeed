@testable import ImageFeed
import XCTest

final class ImageFeedImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterReturnsPhotoInfo() {
        let presenter = ImagesListPresenterFake()
        let photo = Photo(
            id: "someId",
            size: CGSize(),
            createdAt: "3 May 2024",
            welcomeDescription: "Some information about photo",
            thumbImageURL: "https://someWebsite.com/photoThumbImageURL",
            largeImageURL: "https://someWebsite.com/photoLargeImageURL",
            isLiked: false
        )
        let indexPath = IndexPath(row: 0, section: 0)
        
        presenter.photos = [photo]
        
        XCTAssertEqual(presenter.photosCount(), 1)
        XCTAssertEqual(presenter.getThumbImageUrl(for: indexPath), URL(string: photo.thumbImageURL))
        XCTAssertEqual(presenter.getLargeImageUrl(for: indexPath), URL(string: photo.largeImageURL))
        XCTAssertEqual(presenter.getSizeOfImage(for: indexPath), photo.size)
        XCTAssertEqual(presenter.getPhotoCreationDate(for: indexPath), photo.createdAt)
        XCTAssertEqual(presenter.isPhotoLiked(with: indexPath), photo.isLiked)
    }
    
    func testPresenterChangeLike() {
        let presenter = ImagesListPresenterFake()
        let photo = Photo(
            id: "someId",
            size: CGSize(),
            createdAt: "3 May 2024",
            welcomeDescription: "Some information about photo",
            thumbImageURL: "https://someWebsite.com/photoThumbImageURL",
            largeImageURL: "https://someWebsite.com/photoLargeImageURL",
            isLiked: false
        )
        let indexPath = IndexPath(row: 0, section: 0)
        presenter.photos = [photo]
        
        let expectation = XCTestExpectation()
        presenter.changeLike(for: indexPath) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(presenter.photos[indexPath.row].isLiked, true)
    }
}
