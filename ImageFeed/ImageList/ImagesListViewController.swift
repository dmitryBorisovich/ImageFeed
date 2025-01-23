import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var imagesListServiceObserver: NSObjectProtocol? { get set }
    func updateTableViewAnimated(indexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {

    // MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol?

    var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
        presenter?.viewDidLoad()
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
        singleImageVC.imageUrl = presenter?.getLargeImageUrl(for: indexPath)
        singleImageVC.modalTransitionStyle = .coverVertical
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true, completion: nil)
    }
    
    func updateTableViewAnimated(indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard 
            let imagesListCell = cell as? ImagesListCell,
            let imageUrl = presenter?.getThumbImageUrl(for: indexPath)
        else {
            print("Cell type casting failed")
            return UITableViewCell()
        }
        imagesListCell.delegate = self
    
        imagesListCell.configureCell(
            in: tableView,
            at: indexPath,
            imageUrl: imageUrl,
            creationDay: presenter?.getPhotoCreationDate(for: indexPath) ?? "",
            isPhotoLiked: presenter?.isPhotoLiked(with: indexPath) ?? false
        )
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard 
            let imageSize = presenter?.getSizeOfImage(for: indexPath)
        else {
            return tableView.estimatedRowHeight
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scaleFactor = imageViewWidth / imageSize.width
        
        return imageSize.height * scaleFactor + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchToSingleImageVC(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode {
            guard indexPath.row + 1 == presenter?.photosCount() else { return }
            presenter?.loadPhotosPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.changeLike(for: indexPath) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let isPhotoLiked):
                cell.setIsLiked(isPhotoLiked)
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
