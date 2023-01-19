//
//  MaslRenderer.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 11/01/2023.
//

import Foundation
import SwiftUI

struct MaskRenderer {
    let size: CGSize
    let scale: CGFloat
    
    var sizeInPixels: CGSize {
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func image(actions: (CGContext) -> Void) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext.init(
            data: nil,
            width: Int(sizeInPixels.width),
            height: Int(sizeInPixels.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        
        actions(context)
        
        guard let coreImageMask = context.makeImage() else { return nil }
        
        return UIImage(cgImage: coreImageMask)
    }
}

extension UIImage {
    func withMask(_ imageMask: UIImage) -> UIImage? {
        guard let coreImage = cgImage else { return nil }
        guard let coreImageMask = imageMask.cgImage else { return nil }
        guard let coreMaskedImage = coreImage.masking(coreImageMask) else { return nil }
        
        return UIImage(cgImage: coreMaskedImage)
    }
    
}
