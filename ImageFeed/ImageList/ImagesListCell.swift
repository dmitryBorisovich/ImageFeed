import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    private var gradientLayer: CAGradientLayer?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var cellLikeButton: UIButton!
    @IBOutlet private weak var cellDateLabel: UILabel!
    
    // MARK: - Methods
        
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradient()
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
}
