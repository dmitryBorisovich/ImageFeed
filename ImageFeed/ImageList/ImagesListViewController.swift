import UIKit

final class ImagesListViewController: UIViewController {

    // MARK: - Properties
    
    var photos: [Photo] = []
    
    private let service = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
        
        service.fetchPhotosNextPage { _ in }
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                print(">>> [ImagesListViewController] Notification received, updating photos")
                updateTableViewAnimated()
            }
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func switchToSingleImageVC(indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.imageUrl = URL(string: photos[indexPath.row].largeImageURL)
        singleImageVC.modalTransitionStyle = .coverVertical
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true, completion: nil)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = service.photos.count
        photos = service.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Cell type casting failed")
            return UITableViewCell()
        }
        imagesListCell.delegate = self
    
        let image = photos[indexPath.row]
        imagesListCell.configureCell(in: tableView, at: indexPath, withPhoto: image)
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scaleFactor = imageViewWidth / image.size.width
        
        return image.size.height * scaleFactor + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchToSingleImageVC(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == photos.count - 1 else { return }
        service.fetchPhotosNextPage { _ in }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                photos = service.photos
                cell.setIsLiked(photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showLikeErrorAlert()
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить или убрать лайк",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
