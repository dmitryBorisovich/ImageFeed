import UIKit
import SwiftKeychainWrapper
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Private Methods
    
    private func configureBackButton() {
        let backImage = UIImage(named: "blackBackward")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    private func saveTokenToKeyChain(token: String) {
        let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
        guard isSuccess else {
            print("KeyChain adding of token had failed")
            return
        }
    }
}

// MARK: - Extensions

extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let receivedToken):
                guard let self else { return }
                saveTokenToKeyChain(token: receivedToken)
                delegate?.didAuthenticate(self)
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print(">>> [OAuth2Service] Network error. HTTP status code \(statusCode) was received")
                case NetworkError.urlRequestError(let error):
                    print(">>> [OAuth2Service] Network error. URL Request error: \(error.localizedDescription)")
                case NetworkError.urlSessionError:
                    print(">>> [OAuth2Service] Network error. URL Session error: \(error.localizedDescription)")
                case NetworkError.invalidData(let invalidData):
                    print(">>> [OAuth2Service] Network error. Decoding failed: \(error.localizedDescription); Received data: \(invalidData)")
                case AuthServiceError.invalidRequest:
                    print(">>> [OAuth2Service] AuthService error. Failed to complete request")
                case AuthServiceError.extraRequest:
                    print(">>> [OAuth2Service] Attempting to execute a request instead of the current one")
                default:
                    print(">>> [OAuth2Service] Error: \(error.localizedDescription)")
                }
                
                self?.showAuthErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
