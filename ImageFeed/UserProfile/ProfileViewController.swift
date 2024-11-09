import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBackground
        
        let userImageView = addUserImageView()
        let userTextLabels = addUserTextLabels()
        let logOutButton = addLogOutButton()
        
        setupConstraints(image: userImageView, labels: userTextLabels, button: logOutButton)
    }
    
    // MARK: - Private methods
    
    private func addUserImageView() -> UIImageView {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userImageView)
        
        userImageView.tintColor = .gray
        userImageView.layer.cornerRadius = 35
        userImageView.image = UIImage(named: "UserMockImage") ?? UIImage(systemName: "person.crop.circle.fill")
        
        return userImageView
    }
    
    private func addUserTextLabels() -> UIStackView {
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
        view.addSubview(stackView)
        
        return stackView
    }
    
    private func addLogOutButton() -> UIButton {
        let logOutButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(logOutButtonPressed)
        )
        logOutButton.tintColor = .ypRed
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logOutButton)
        
        return logOutButton
    }
    
    private func setupConstraints(image: UIImageView, labels: UIStackView, button: UIButton) {
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 70),
            image.heightAnchor.constraint(equalToConstant: 70),
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            image.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14)
        ])
        
        NSLayoutConstraint.activate([
            labels.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            labels.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labels.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 8)
        ])
    }
    
    @objc private func logOutButtonPressed() {
        
    }
}
