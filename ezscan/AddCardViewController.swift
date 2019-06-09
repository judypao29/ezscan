//
//  AddCardViewController.swift
//  ezscan
//
//  Created by Judy Pao on 6/8/19.
//

import UIKit
import Vision
import AVFoundation

class AddCardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var takeAPictureButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameOfCard: UITextField!
    
    let imageDataManager: ImageDataManager = ImageDataManager()
    
    var imagePicker: UIImagePickerController!
    var scanner: Scanner? 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        takeAPictureButton.addTarget(self, action: #selector(takePic(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePic(_:)), for: .touchUpInside)
    }
    
    @objc func takePic(_: Any) {
        takePhoto(self)
    }
    
    @objc func savePic(_: Any) {
        if let imageToSave = cardPicture.image {
            imageDataManager.storeImage(image: imageToSave, name: nameOfCard.text!)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)

        if let img = info[.originalImage] as? UIImage {
            parseImage(image: img)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func parseImage(image: UIImage) {
        image.detector.crop(type: .barcode) { [weak self] result in
            switch result {
            case .success(let croppedImages):
                self?.cardPicture.image = croppedImages[0]
                print("Found")
            case .notFound:
                print("Not Found")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
