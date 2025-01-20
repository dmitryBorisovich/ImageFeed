import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logOut()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        guard
            let profile = ProfileService.shared.profile
        else { return }
        
        view?.updateUserDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )
        
        view?.profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                print(">>> [ProfileViewController] Notification received, updating avatar")
                updateAvatar()
            }
        
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(with: url)
    }
    
    func logOut() {
        ProfileLogoutService.shared.logout()
    }
}
