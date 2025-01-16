import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    var updateUserDetailsCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var updateAvatarCounter = 0
    
    func updateUserDetails(name: String, loginName: String, bio: String) {
        updateUserDetailsCalled = true
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        updateAvatarCounter += 1
    }
}
