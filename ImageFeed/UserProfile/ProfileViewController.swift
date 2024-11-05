import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userTextLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IB Actions
    
    @IBAction func logOutButtonPressed() {
        
    }
}
