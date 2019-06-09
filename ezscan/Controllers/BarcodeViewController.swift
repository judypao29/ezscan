import UIKit


class BarcodeViewController: UIViewController {
    @IBOutlet weak var barcodeDisplay: UIImageView!
    @IBOutlet weak var cardName: UILabel!
    
    var name: String?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Scan Barcode"
        barcodeDisplay?.image = image
        cardName?.text = name
    }
}
