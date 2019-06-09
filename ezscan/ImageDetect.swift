import UIKit
import Vision

extension NSObject: ImageCroppable {}
extension CGImage: ImageCroppable {}
public protocol ImageCroppable {}

public enum DetectionType {
    case barcode
}

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
        let width = 800
        let height = object.boundingBox.height * CGFloat(self.detectable.height)
        let x = object.boundingBox.origin.x * CGFloat(self.detectable.width)
        let y = (1 - object.boundingBox.origin.y) * CGFloat(self.detectable.height) - height

        let croppingRect = CGRect(x: x - (height/5), y: y , width: CGFloat(width), height: height)
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

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
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
                let barcode = cgImages.map { cgImage -> UIImage in
                    return UIImage(cgImage: cgImage)
                }
                completion(.success(barcode))
            case .notFound:
                completion(.notFound)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}
