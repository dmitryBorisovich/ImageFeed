import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func configureBackButton() {
        let backImage = UIImage(named: "blackBackward")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
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
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let receivedToken):
                guard let self else { return }
                OAuth2TokenStorage.shared.token = receivedToken
                delegate?.didAuthenticate(self)
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print(">>> Network error: HTTP status code \(statusCode) was received")
                case NetworkError.urlRequestError(let error):
                    print(">>> URL Request error: \(error.localizedDescription)")
                case NetworkError.urlSessionError:
                    print(">>> URL Session error")
                default:
                    print(">>> Unknown error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
