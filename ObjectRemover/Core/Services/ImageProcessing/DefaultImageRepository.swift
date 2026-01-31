//
//  DefaultImageRepository.swift
//  ObjectRemover
//
//  Default implementation of ImageRepositoryProtocol.
//  Handles loading images from Photos library and saving processed images.
//

import UIKit
import Photos

final class DefaultImageRepository: ImageRepositoryProtocol {

    // MARK: - Private Properties

    private let imageManager = PHCachingImageManager()

    // MARK: - Load Full Resolution

    func loadFullResolution(from asset: PHAsset) async throws -> UIImage {
        try await loadImage(from: asset, quality: .original)
    }

    // MARK: - Load with Quality

    func loadImage(from asset: PHAsset, quality: ImageQuality) async throws -> UIImage {
        let targetSize: CGSize

        if let maxDimension = quality.maxDimension {
            // Calculate target size maintaining aspect ratio
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            if aspectRatio > 1 {
                targetSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                targetSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            }
        } else {
            // Original size
            targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        }

        return try await loadImage(from: asset, targetSize: targetSize)
    }

    // MARK: - Load with Target Size

    func loadImage(from asset: PHAsset, targetSize: CGSize) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            options.resizeMode = .exact

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: ImageRepositoryError.loadFailed(underlying: error))
                    return
                }

                if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                    continuation.resume(throwing: ImageRepositoryError.loadFailed(underlying: nil))
                    return
                }

                if let degraded = info?[PHImageResultIsDegradedKey] as? Bool, degraded {
                    // Skip degraded results, wait for full quality
                    return
                }

                guard let image = image else {
                    continuation.resume(throwing: ImageRepositoryError.assetNotFound)
                    return
                }

                continuation.resume(returning: image)
            }
        }
    }

    // MARK: - Save to Photos Library

    @discardableResult
    func saveToPhotosLibrary(_ image: UIImage) async throws -> String {
        var localIdentifier: String?

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
        }

        guard let identifier = localIdentifier else {
            throw ImageRepositoryError.saveFailed(underlying: nil)
        }

        return identifier
    }

    // MARK: - Save to Temporary File

    func saveToTemporaryFile(_ image: UIImage, format: ImageFormat) async throws -> URL {
        let fileName = UUID().uuidString + "." + format.fileExtension
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let data: Data?
        switch format {
        case .jpeg:
            data = image.jpegData(compressionQuality: format.compressionQuality)
        case .png:
            data = image.pngData()
        case .heic:
            // Fallback to JPEG for HEIC if not supported
            data = image.jpegData(compressionQuality: format.compressionQuality)
        }

        guard let imageData = data else {
            throw ImageRepositoryError.exportFailed
        }

        do {
            try imageData.write(to: tempURL)
            return tempURL
        } catch {
            throw ImageRepositoryError.saveFailed(underlying: error)
        }
    }

    // MARK: - Memory Check

    func canProcessImage(ofSize size: CGSize) -> MemoryCheckResult {
        MemoryChecker.canProcess(imageSize: size, operationType: .objectRemoval)
    }

    // MARK: - Scaling

    func scaleImageForProcessing(_ image: UIImage, recommendedScale: CGFloat) -> UIImage {
        ImageScaler.scaleDown(image, by: recommendedScale)
    }

    func upscaleToOriginal(processedImage: UIImage, originalSize: CGSize) -> UIImage {
        ImageScaler.restoreOriginalSize(processedImage: processedImage, originalSize: originalSize)
    }
}
