import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    private lazy var cellImageView: UIImageView = {
        let cellImageView = UIImageView()
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.backgroundColor = .ypWhiteAlpha50
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
        return cellImageView
    }()
    
    private lazy var cellLikeButton: UIButton = {
        let cellLikeButton = UIButton()
        cellLikeButton.translatesAutoresizingMaskIntoConstraints = false
        cellLikeButton.setImage(UIImage(named: "LikeNoActive"), for: .normal)
        cellLikeButton.addTarget(
            self,
            action: #selector(likeButtonPressed),
            for: .touchUpInside
        )
        return cellLikeButton
    }()
    
    private lazy var cellDateLabel: UILabel = {
        let cellDateLabel = UILabel()
        cellDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cellDateLabel.font = UIFont.systemFont(ofSize: 13)
        cellDateLabel.textColor = .ypWhite
        cellDateLabel.text = dateFormatter.string(from: Date())
        return cellDateLabel
    }()
    
    private lazy var placeholder: UIImageView = {
        let placeholder = UIImageView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.image = UIImage(named: "LoadingImage")
        return placeholder
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        placeholder.isHidden = false
    }
    
    private func setUpCell() {
        self.backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        [cellImageView, cellDateLabel, cellLikeButton, placeholder].forEach { contentView.addSubview($0) }
        setUpConstraints()
        configureGradient()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            cellDateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            cellDateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            cellDateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: cellImageView.trailingAnchor, constant: -8),
            
            cellLikeButton.widthAnchor.constraint(equalToConstant: 44),
            cellLikeButton.heightAnchor.constraint(equalToConstant: 44),
            cellLikeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            cellLikeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            
            placeholder.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: cellImageView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImageView.bounds.height - 30,
            width: cellImageView.bounds.width,
            height: 30
        )
    }
    
    private func configureGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0,
            y: cellImageView.bounds.height - 30,
            width: cellImageView.bounds.width,
            height: 30
        )
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
            
        cellImageView.layer.addSublayer(gradientLayer)
            
        self.gradientLayer = gradientLayer
    }
    
    func configureCell(in tableView: UITableView, at indexPath: IndexPath, withPhoto photo: Photo) {
        placeholder.isHidden = false
        let imageUrl = URL(string: photo.thumbImageURL)
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(
            with: imageUrl
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                placeholder.isHidden = true
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(">>> [ImageListCell] Loading image in cell failed: \(error.localizedDescription)")
            }
        }

        cellDateLabel.text = formatDate(photo.createdAt)
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "LikeActive") : UIImage(named: "LikeNoActive")
        cellLikeButton.setImage(likeImage, for: .normal)
        
        self.selectionStyle = .none
    }
    
    private func formatDate(_ date: String?) -> String {
        guard let date else { return "" }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let formattedDate = dateFormatter.date(from: date) else { return "" }
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: formattedDate)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "LikeActive") : UIImage(named: "LikeNoActive")
        cellLikeButton.setImage(likeImage, for: .normal)
    }
    
    @objc private func likeButtonPressed() {
        delegate?.imageListCellDidTapLike(self)
    }
}
