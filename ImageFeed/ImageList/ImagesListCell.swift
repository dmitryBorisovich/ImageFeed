import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellDateLabel: UILabel!
        
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
}
