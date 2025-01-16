import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func getUrlForAvatar() -> URL?
    func logOut()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profile: Profile?
    private var profileImageURL: String?

    init(
        profile: Profile? = ProfileService.shared.profile,
        profileImageURL: String? = ProfileImageService.shared.avatarURL
    ){
        self.profile = profile
        self.profileImageURL = profileImageURL
    }
    
    func viewDidLoad() {
        guard 
            let profile,
            let url = getUrlForAvatar()
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
                view?.updateAvatar(with: url)
            }
        
        view?.updateAvatar(with: url)
    }
    
    func getUrlForAvatar() -> URL? {
        guard let profileImageURL else { return nil }
        return URL(string: profileImageURL)
    }
    
//    func addObserverForImage() {
//        
//    }
    
    func logOut() {
        ProfileLogoutService.shared.logout()
    }
}
