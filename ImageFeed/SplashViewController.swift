import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.image = UIImage(named: "LaunchScreenLogo")
        return logoImage
    }()
    
    private let showAuthViewSegueIdentifier = "showAuthView"
    private var username: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(">>> [SplashViewController] SplashVC did appear")
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token)
        } else {
            switchToAuthViewController()
        }
    }
    
    // MARK: - Private Methods
    
    private func setUpScreen() {
        view.addSubview(logoImage)
        view.backgroundColor = UIColor.ypBlack
        
        NSLayoutConstraint.activate([
            logoImage.widthAnchor.constraint(equalToConstant: 75),
            logoImage.heightAnchor.constraint(equalToConstant: 77.68),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            
            print(">>> [ProfileService] Fetching profile...")
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                username = profile.username
                guard let username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                print(">>> [SplashViewController] Fetching profile completed")
                switchToTabBarController()
            case .failure:
                print(">>> [SplashViewController] Fetching profile failed")
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure(">>> [SplashViewController] Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
           
        window.rootViewController = tabBarController
    }
    
    private func switchToAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        fetchProfile(token)
    }
}
