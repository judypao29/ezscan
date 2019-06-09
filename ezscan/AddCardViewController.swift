//
//  AddCardViewController.swift
//  ezscan
//
//  Created by Judy Pao on 6/8/19.
//

import UIKit

class AddCardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var takeAPictureButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeAPictureButton.addTarget(self, action: #selector(takePic(_:)), for: .touchUpInside)
    }
    
    @objc func takePic(_: Any) {
        takePhoto(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        cardPicture.image = info[.originalImage] as? UIImage
    }
    
    @IBAction func takePhoto(_ sender: Any){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
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
