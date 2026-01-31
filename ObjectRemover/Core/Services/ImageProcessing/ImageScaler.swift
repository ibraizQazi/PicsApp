//
//  ImageScaler.swift
//  ObjectRemover
//
//  Utility for scaling images up and down for memory-efficient processing.
//

import UIKit

final class ImageScaler {

    // MARK: - Scale Down

    /// Scale an image down by a factor
    static func scaleDown(_ image: UIImage, by scale: CGFloat) -> UIImage {
        guard scale < 1.0 else { return image }

        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        return resize(image, to: newSize)
    }

    /// Scale an image to fit within a maximum dimension
    static func scaleToFit(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let maxSide = max(image.size.width, image.size.height)
        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        return scaleDown(image, by: scale)
    }

    // MARK: - Scale Up

    /// Scale an image up to a target size
    static func scaleUp(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        guard image.size.width < targetSize.width || image.size.height < targetSize.height else {
            return image
        }

        return resize(image, to: targetSize)
    }

    /// Scale an image back to its original size after processing
    static func restoreOriginalSize(
        processedImage: UIImage,
        originalSize: CGSize
    ) -> UIImage {
        guard processedImage.size != originalSize else {
            return processedImage
        }

        return resize(processedImage, to: originalSize)
    }

    // MARK: - Resize

    /// Resize an image to a specific size using high-quality interpolation
    static func resize(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.preferredRange = .extended

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { context in
            // Use high-quality interpolation
            context.cgContext.interpolationQuality = .high
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // MARK: - Aspect Fit

    /// Calculate size that fits within bounds while maintaining aspect ratio
    static func sizeThatFits(
        imageSize: CGSize,
        within bounds: CGSize
    ) -> CGSize {
        let widthRatio = bounds.width / imageSize.width
        let heightRatio = bounds.height / imageSize.height
        let scale = min(widthRatio, heightRatio)

        return CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
    }

    /// Calculate size that fills bounds while maintaining aspect ratio
    static func sizeThatFills(
        imageSize: CGSize,
        within bounds: CGSize
    ) -> CGSize {
        let widthRatio = bounds.width / imageSize.width
        let heightRatio = bounds.height / imageSize.height
        let scale = max(widthRatio, heightRatio)

        return CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
    }
}
