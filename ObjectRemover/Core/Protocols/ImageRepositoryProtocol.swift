//
//  ImageRepositoryProtocol.swift
//  ObjectRemover
//
//  Protocol abstraction for image loading, saving, and management.
//

import UIKit
import Photos
import Combine

// MARK: - Image Format

enum ImageFormat: String, CaseIterable {
    case jpeg = "jpeg"
    case png = "png"
    case heic = "heic"

    var fileExtension: String { rawValue }

    var mimeType: String {
        switch self {
        case .jpeg: return "image/jpeg"
        case .png: return "image/png"
        case .heic: return "image/heic"
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .jpeg: return 0.9
        case .png: return 1.0
        case .heic: return 0.9
        }
    }
}

// MARK: - Image Quality

enum ImageQuality {
    case original
    case high      // 2048px max dimension
    case medium    // 1024px max dimension
    case low       // 512px max dimension
    case thumbnail // 256px max dimension
    case custom(maxDimension: CGFloat)

    var maxDimension: CGFloat? {
        switch self {
        case .original: return nil
        case .high: return 2048
        case .medium: return 1024
        case .low: return 512
        case .thumbnail: return 256
        case .custom(let max): return max
        }
    }
}

// MARK: - Errors

enum ImageRepositoryError: Error, LocalizedError {
    case assetNotFound
    case loadFailed(underlying: Error?)
    case saveFailed(underlying: Error?)
    case unauthorized
    case invalidImage
    case iCloudDownloadFailed
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .assetNotFound:
            return "Image not found in photo library"
        case .loadFailed(let error):
            return "Failed to load image: \(error?.localizedDescription ?? "Unknown error")"
        case .saveFailed(let error):
            return "Failed to save image: \(error?.localizedDescription ?? "Unknown error")"
        case .unauthorized:
            return "Not authorized to access photo library"
        case .invalidImage:
            return "Invalid image data"
        case .iCloudDownloadFailed:
            return "Failed to download image from iCloud"
        case .exportFailed:
            return "Failed to export image"
        }
    }
}

// MARK: - Protocol

protocol ImageRepositoryProtocol: AnyObject {
    /// Load an image from a photo asset at full resolution
    func loadFullResolution(from asset: PHAsset) async throws -> UIImage

    /// Load an image from a photo asset at specified quality
    func loadImage(from asset: PHAsset, quality: ImageQuality) async throws -> UIImage

    /// Load an image from a photo asset with specific target size
    func loadImage(from asset: PHAsset, targetSize: CGSize) async throws -> UIImage

    /// Save an image to the Photos library
    /// - Returns: The local identifier of the saved asset
    @discardableResult
    func saveToPhotosLibrary(_ image: UIImage) async throws -> String

    /// Save an image to a temporary file
    func saveToTemporaryFile(_ image: UIImage, format: ImageFormat) async throws -> URL

    /// Check if an image can be processed given memory constraints
    func canProcessImage(ofSize size: CGSize) -> MemoryCheckResult

    /// Scale an image to fit within memory constraints
    func scaleImageForProcessing(_ image: UIImage, recommendedScale: CGFloat) -> UIImage

    /// Upscale a processed image back to original resolution
    func upscaleToOriginal(processedImage: UIImage, originalSize: CGSize) -> UIImage
}
