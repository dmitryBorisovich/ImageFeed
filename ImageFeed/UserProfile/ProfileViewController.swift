import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    
    private lazy var userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.tintColor = .gray
        userImageView.layer.cornerRadius = 35
        userImageView.image = UIImage(named: "UserMockImage") ?? UIImage(systemName: "person.crop.circle.fill")
        return userImageView
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .ypWhite
        
        let userIdLabel = UILabel()
        userIdLabel.text = "@ekaterina_nov"
        userIdLabel.font = .systemFont(ofSize: 13)
        userIdLabel.textColor = .ypGray
        
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.text = "Hello, world!"
        userDescriptionLabel.font = .systemFont(ofSize: 13)
        userDescriptionLabel.textColor = .ypWhite
        
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
        
        view.backgroundColor = .ypBackground
        
        addSubViews()
        setupConstraints()
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
    
    @objc private func logOutButtonPressed() {}
}
