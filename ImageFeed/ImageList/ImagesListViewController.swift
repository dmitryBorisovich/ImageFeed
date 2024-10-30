import UIKit

final class ImagesListViewController: UIViewController {

    // MARK: - IB Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
    }
    
    func configCell(for cell: ImagesListCell) {
        
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Cell type casting failed")
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell)
        
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

