//
//  BarcodeViewController.swift
//  ezscan
//
//  Created by Judy Pao on 6/9/19.
//

import UIKit


class BarcodeViewController: UIViewController {
    @IBOutlet weak var barcodeDisplay: UIImageView!
    @IBOutlet weak var cardName: UILabel!
    
    var name: String?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeDisplay?.image = image
        cardName?.text = name
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
