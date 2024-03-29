import Foundation
import UIKit
import CoreData

class ImageDataManager {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func storeImageInfo(image: UIImage, name: String) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        
        if let binaryImage = image.pngData() {
            let imageToStore = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context)
            imageToStore.setValue(binaryImage, forKey: "image")
            imageToStore.setValue(name, forKey: "name")
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("failed to save")
                }
            }
        }
        return false
    }
}
