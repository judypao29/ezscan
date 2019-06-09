//
//  ImageDetect.swift
//  ImageDetect
//
//  Created by Arthur Sahakyan on 3/17/18.
//

import UIKit
import Vision

extension NSObject: ImageCroppable {}
extension CGImage: ImageCroppable {}
public protocol ImageCroppable {}

/**
 This enumeration is for identification of detection type
 
 - face: for cropping faces
 - barcode: for croping barcodes
 - text: for cropping text rectangles
 */
public enum DetectionType {
    case face
    case barcode
    case text
}

/**
 This enumeration is for identification of request type
 
 - success: successfuly cropted objects
 - notFound: not found some object of `DetectionType` in image
 - failure: failed with error
 */
public enum ImageDetectResult<T> {
    case success([T])
    case notFound
    case failure(Error)
}

public struct ImageDetect<T> {
    let detectable: T
    init(_ detectable: T) {
        self.detectable = detectable
    }
}

public extension ImageCroppable {
    var detector: ImageDetect<Self> {
        return ImageDetect(self)
    }
}

public extension ImageDetect where T: CGImage {
    
    /**
     To crop object in image
     - parameter type: type of object that must be croped
     - parameter completion: callbeck with `ImageDetectResult<T>` with error or success response
     */
    func crop(completion: @escaping (ImageDetectResult<CGImage>) -> Void) {
        cropBarcode(completion)
    }

    private func cropBarcode(_ completion: @escaping (ImageDetectResult<CGImage>) -> Void) {
        guard #available(iOS 11.0, *) else {
            return
        }
        
        let req = VNDetectBarcodesRequest { request, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            let codeImages = request.results?.map({ result -> CGImage? in
                guard let code = result as? VNBarcodeObservation else { return nil }
                let codeImage = self.cropImage(object: code)
                return codeImage
            }).compactMap { $0 }
            
            guard let result = codeImages, result.count > 0 else {
                completion(.notFound)
                return
            }
            
            completion(.success(result))
        }
        
        do {
            try VNImageRequestHandler(cgImage: self.detectable, options: [:]).perform([req])
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func cropImage(object: VNDetectedObjectObservation) -> CGImage? {
        let width = object.boundingBox.width * CGFloat(self.detectable.width)
        let height = object.boundingBox.height * CGFloat(self.detectable.height)
        let x = object.boundingBox.origin.x * CGFloat(self.detectable.width)
        let y = (1 - object.boundingBox.origin.y) * CGFloat(self.detectable.height) - height

        let croppingRect = CGRect(x: x - (height/5), y: y , width: 800, height: height)
        
//        let croppingRect = CGRect(x: 10, y: 10, width: 200, height: 200)

        let image = self.detectable.cropping(to: croppingRect)!
        
        let uiimage: UIImage = UIImage(cgImage: image)
        let rotated: UIImage = uiimage.rotate(radians: .pi/2)!
        let ciimage: CIImage = CIImage(image: rotated)!
        
        let context = CIContext(options: nil)
        return context.createCGImage(ciimage, from: ciimage.extent)
    }
}

public extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

public extension ImageDetect where T: UIImage {
    
    func crop(type: DetectionType, completion: @escaping (ImageDetectResult<UIImage>) -> Void) {
        guard #available(iOS 11.0, *) else {
            return
        }
        
        self.detectable.cgImage!.detector.crop() { result in
            switch result {
            case .success(let cgImages):
                let faces = cgImages.map { cgImage -> UIImage in
                    return UIImage(cgImage: cgImage)
                }
                completion(.success(faces))
            case .notFound:
                completion(.notFound)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}
