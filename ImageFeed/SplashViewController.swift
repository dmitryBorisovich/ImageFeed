import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let showAuthViewSegueIdentifier = "showAuthView"
    private var username: String?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(">>> [SplashViewController] SplashVC did appear")
        
        if let token = KeychainWrapper.standard.string(forKey: "Auth token") {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private Methods
    
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
                fetchProfileImage(username: username)
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print(">>> [ProfileService] Network error. HTTP status code \(statusCode) was received")
                case NetworkError.urlRequestError(let error):
                    print(">>> [ProfileService] Network error. URL Request error: \(error.localizedDescription)")
                case NetworkError.urlSessionError:
                    print(">>> [ProfileService] Network error. URL Session error: \(error.localizedDescription)")
                case NetworkError.invalidData(let invalidData):
                    print(">>> [ProfileService] Network error. Decoding failed: \(error.localizedDescription); Received data: \(invalidData)")
                case ProfileServiceError.invalidRequest:
                    print(">>> [ProfileService] ProfileService error. Failed to complete request")
                case ProfileServiceError.extraRequest:
                    print(">>> [ProfileService] Attempting to execute a request instead of the current one")
                default:
                    print(">>> Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            
            print(">>> [ProfileImageService] Fetching profile image...")
            
            switch result {
            case .success(let imageURL):
                print(">>> [ProfileImageService] The profile image has been loaded: \(imageURL)\n")
                self.switchToTabBarController()
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print(">>> [ProfileImageService] Network error. HTTP status code \(statusCode) was received")
                case NetworkError.urlRequestError(let error):
                    print(">>> [ProfileImageService] Network error. URL Request error: \(error.localizedDescription)")
                case NetworkError.urlSessionError:
                    print(">>> [ProfileImageService] Network error. URL Session error: \(error.localizedDescription)")
                case NetworkError.invalidData(let invalidData):
                    print(">>> [ProfileImageService] Network error. Decoding failed: \(error.localizedDescription); Received data: \(invalidData)")
                case ProfileImageServiceError.invalidRequest:
                    print(">>> [ProfileImageService] ProfileImageService error. Failed to complete request")
                case ProfileImageServiceError.extraRequest:
                    print(">>> [ProfileImageService] Attempting to execute a request instead of the current one")
                default:
                    print(">>> [ProfileImageService] Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

// MARK: - Extensions

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthViewSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = KeychainWrapper.standard.string(forKey: "Auth token") else { return }
        fetchProfile(token)
    }
}
