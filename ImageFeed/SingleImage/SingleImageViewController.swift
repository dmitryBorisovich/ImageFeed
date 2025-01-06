import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var imageUrl: URL?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let backButton = UIButton.systemButton(
            with: UIImage(named: "Backward") ?? UIImage(),
            target: self,
            action: #selector(backButtonPressed)
        )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .ypWhite
        return backButton
    }()
    
    private lazy var shareButton: UIButton = {
        let shareButton = UIButton.systemButton(
            with: UIImage(named: "Sharing")?.withRenderingMode(.alwaysOriginal) ?? UIImage(),
            target: self,
            action: #selector(shareButtonPressed)
        )
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        return shareButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    // MARK: - Private methods
    
    private func setUpScreen() {
        view.backgroundColor = .ypBlack
        [scrollView, backButton, shareButton].forEach { view.addSubview($0) }
        scrollView.addSubview(imageView)
        setUpConstraints()
        loadImage()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            shareButton.widthAnchor.constraint(equalToConstant: 51),
            shareButton.heightAnchor.constraint(equalToConstant: 51),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func updateContentInset() {
        let horizontalInset = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let verticalInset = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        
        let closeAlertAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            self.dismiss(animated: true)
        }
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadImage()
        }
        
        [closeAlertAction, retryAction].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    private func loadImage() {
        guard let imageUrl else { return }
        
        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    @objc private func backButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc private func shareButtonPressed() {
        guard let image = imageView.image else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension SingleImageViewController: UIScrollViewDelegate {
   
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
