import UIKit
import Vision
import AVFoundation
import CoreData

class AddCardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var cardPicture: UIImageView!
    @IBOutlet weak var takeAPictureButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameOfCard: UITextField!
    
    let imageDataManager: ImageDataManager = ImageDataManager()
    let container = NSPersistentContainer(name: "ezscan")

    var imagePicker: UIImagePickerController!
    var scanner: Scanner?
    var found = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5
        takeAPictureButton.layer.cornerRadius = 5
        self.navigationItem.title = "New Card"
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        takeAPictureButton.addTarget(self, action: #selector(takePic(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePic(_:)), for: .touchUpInside)
    }
    
    @objc func takePic(_: Any) {
        takePhoto(self)
    }
    
    @objc func savePic(_: Any) {
        if let imageToSave = cardPicture.image {
            if imageDataManager.storeImageInfo(image: imageToSave, name: nameOfCard.text!) {
                let alert = UIAlertController(title: "Success!", message: "Your card has been saved", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    UIAlertAction in
                }
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            saveContext()
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        request.returnsObjectsAsFaults = false
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
    
    func parseImage(image: UIImage){
        image.detector.crop(type: .barcode){ [weak self] result in
            
            switch result {
            case .success(var croppedImages):
                
                self?.cardPicture.image = croppedImages[0]

                print("Found")
                self?.found = true
                croppedImages.remove(at: 0)
            case .notFound:
                let alert = UIAlertController(title: "Error", message: "Please retake the photo", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                self?.present(alert, animated: true, completion: nil)
                self?.found = false
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
