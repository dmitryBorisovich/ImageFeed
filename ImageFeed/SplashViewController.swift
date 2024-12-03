import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthViewSegueIdentifier = "showAuthView"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(">>> SplashVC did appear")
        
        let token = OAuth2TokenStorage.shared.token
        if let token {
            fetchProfile(token)
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print(">>> Network error: HTTP status code \(statusCode) was received")
                case NetworkError.urlRequestError(let error):
                    print(">>> URL Request error: \(error.localizedDescription)")
                case NetworkError.urlSessionError:
                    print(">>> URL Session error")
                case ProfileServiceError.invalidRequest:
                    print(">>> Invalid request")
                default:
                    print(">>> Error: \(error.localizedDescription)")
                }
                break
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
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        fetchProfile(token)
    }
}
