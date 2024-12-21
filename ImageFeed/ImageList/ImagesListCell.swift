import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    private lazy var cellImageView: UIImageView = {
        let cellImageView = UIImageView()
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
        return cellImageView
    }()
    
    private lazy var cellLikeButton: UIButton = {
        let cellLikeButton = UIButton()
        cellLikeButton.translatesAutoresizingMaskIntoConstraints = false
        cellLikeButton.setImage(UIImage(named: "LikeNoActive"), for: .normal)
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
    
    private var gradientLayer: CAGradientLayer?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setUpCell() {
        self.backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        [cellImageView, cellDateLabel, cellLikeButton].forEach { contentView.addSubview($0) }
        setUpConstraints()
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
            cellLikeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradient()
    }
    
    private func configureGradient() {
        gradientLayer?.removeFromSuperlayer()
            
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
    
    func configureCell(withIndex index: IndexPath) {
        guard let cellImage = UIImage(named: "\(index.row)") else { return }
        
        cellImageView.image = cellImage
        cellDateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = index.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "LikeActive") : UIImage(named: "LikeNoActive")
        cellLikeButton.setImage(likeImage, for: .normal)
        
        self.selectionStyle = .none
    }
}
