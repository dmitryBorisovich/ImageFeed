import UIKit
import SwiftKeychainWrapper
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "UnsplashLogo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    private lazy var startAuthButton: UIButton = {
        let startAuthButton = UIButton()
        startAuthButton.setTitle("Войти", for: .normal)
        startAuthButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        startAuthButton.setTitleColor(.ypBlack, for: .normal)
        startAuthButton.backgroundColor = .ypWhite
        startAuthButton.layer.masksToBounds = true
        startAuthButton.layer.cornerRadius = 16
        startAuthButton.addTarget(
            self,
            action: #selector(startAuthButtonPressed),
            for: .touchUpInside
        )
        startAuthButton.translatesAutoresizingMaskIntoConstraints = false
        return startAuthButton
    }()
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    // MARK: - Private Methods
    
    private func setUpScreen() {
        view.backgroundColor = .ypBlack
        [logo, startAuthButton].forEach { view.addSubview($0) }
        setUpConstraints()
        configureBackButton()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            startAuthButton.heightAnchor.constraint(equalToConstant: 48),
            startAuthButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startAuthButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startAuthButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            
            logo.widthAnchor.constraint(equalToConstant: 60),
            logo.heightAnchor.constraint(equalToConstant: 60),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
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
    
    @objc private func startAuthButtonPressed() {
        let webView = WebViewViewController()
        webView.delegate = self
        if let navigationController {
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.pushViewController(webView, animated: true)
        }
    }
}

// MARK: - Extensions

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let receivedToken):
                OAuth2TokenStorage.shared.token = receivedToken
                delegate?.didAuthenticate(self)
            case .failure:
                showAuthErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
