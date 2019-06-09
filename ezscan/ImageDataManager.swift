//
//  ImageDataManager.swift
//  ezscan
//
//  Created by Judy Pao on 6/8/19.
//

import Foundation
import UIKit
import CoreData

class ImageDataManager {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func storeImage(image: UIImage, name: String) {
        let context = appDelegate.persistentContainer.viewContext
        
        if let binaryImage = image.pngData() {
            let imageToStore = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context)
            imageToStore.setValue(binaryImage, forKey: "image")
            imageToStore.setValue(name, forKey: "name")
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
}
