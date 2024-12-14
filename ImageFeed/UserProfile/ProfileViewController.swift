import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.tintColor = .gray
        userImageView.layer.cornerRadius = 35
        userImageView.image = UIImage(systemName: "person.crop.circle.fill")
        return userImageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .ypWhite
        return userNameLabel
    }()
    
    private lazy var userIdLabel: UILabel = {
        let userIdLabel = UILabel()
        userIdLabel.text = "@ekaterina_nov"
        userIdLabel.font = .systemFont(ofSize: 13)
        userIdLabel.textColor = .ypGray
        return userIdLabel
    }()
    
    private lazy var userDescriptionLabel: UILabel = {
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.text = "Hello, world!"
        userDescriptionLabel.font = .systemFont(ofSize: 13)
        userDescriptionLabel.textColor = .ypWhite
        return userDescriptionLabel
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            userNameLabel,
            userIdLabel,
            userDescriptionLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var logOutButton: UIButton = {
        let logOutButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(logOutButtonPressed)
        )
        logOutButton.tintColor = .ypRed
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        return logOutButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(">>> [ProfileViewController] ProfileVC did load")
        
        addSubViews()
        setupConstraints()
        
        view.backgroundColor = .ypBlack
        userImageView.layer.cornerRadius = 35
        userImageView.clipsToBounds = true
        
        guard let profile = ProfileService.shared.profile else { return }
        
        updateUserDetails(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
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
    
    // MARK: - Private methods
    
    private func addSubViews() {
        [userImageView, labelsStackView, logOutButton].forEach { view.addSubview($0)}
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 70),
            userImageView.heightAnchor.constraint(equalToConstant: 70),
            userImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            userImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            labelsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            labelsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            logOutButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14)
        ])
    }
    
    private func updateUserDetails(profile: Profile) {
        userNameLabel.text = profile.name
        userIdLabel.text = profile.loginName
        userDescriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        print(">>> [ProfileViewController] Updating avatar with URL: \(profileImageURL)\n")
    
        userImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle.fill")
        )
    }
    
    @objc private func logOutButtonPressed() {}
}
