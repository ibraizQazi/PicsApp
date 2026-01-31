//
//  ObjectRemovalServiceProtocol.swift
//  ObjectRemover
//
//  Protocol abstraction for object removal service.
//  Can be implemented with CoreML model, external API, or dummy implementation.
//

import UIKit
import Combine

// MARK: - Result Types

struct RemovalResult {
    let processedImage: UIImage
    let maskUsed: UIImage
    let processingTimeSeconds: Double
}

struct MemoryCheckResult {
    let canProcess: Bool
    let availableMemoryMB: Double
    let requiredMemoryMB: Double
    let recommendedScale: CGFloat

    var message: String {
        if canProcess {
            return "Image can be processed at full resolution"
        } else {
            let scalePercent = Int(recommendedScale * 100)
            return "Insufficient memory. Recommended scale: \(scalePercent)%"
        }
    }
}

// MARK: - Errors

enum ObjectRemovalError: Error, LocalizedError {
    case serviceNotReady
    case invalidMask
    case invalidImage
    case processingFailed(underlying: Error)
    case insufficientMemory(required: Double, available: Double)
    case cancelled
    case timeout

    var errorDescription: String? {
        switch self {
        case .serviceNotReady:
            return "Object removal service is not ready"
        case .invalidMask:
            return "The provided mask is invalid"
        case .invalidImage:
            return "The provided image is invalid"
        case .processingFailed(let underlying):
            return "Processing failed: \(underlying.localizedDescription)"
        case .insufficientMemory(let required, let available):
            return "Insufficient memory. Required: \(Int(required))MB, Available: \(Int(available))MB"
        case .cancelled:
            return "Operation was cancelled"
        case .timeout:
            return "Operation timed out"
        }
    }
}

// MARK: - Protocol

protocol ObjectRemovalServiceProtocol: AnyObject {
    /// Whether the service is ready to process images
    var isReady: Bool { get }

    /// Publisher for service readiness state changes
    var isReadyPublisher: AnyPublisher<Bool, Never> { get }

    /// Prepare the service (load models, initialize resources)
    func prepare() async throws

    /// Remove objects from an image using the provided mask
    /// - Parameters:
    ///   - image: The source image
    ///   - mask: Binary mask where white indicates areas to remove
    /// - Returns: The processed image with objects removed
    func removeObjects(from image: UIImage, mask: UIImage) async throws -> RemovalResult

    /// Remove objects with progress reporting
    /// - Parameters:
    ///   - image: The source image
    ///   - mask: Binary mask where white indicates areas to remove
    ///   - progress: Progress callback (0.0 to 1.0)
    /// - Returns: The processed image with objects removed
    func removeObjects(
        from image: UIImage,
        mask: UIImage,
        progress: @escaping (Double) -> Void
    ) async throws -> RemovalResult

    /// Cancel any ongoing processing
    func cancelProcessing()

    /// Check if an image can be processed given current memory constraints
    func canProcess(imageSize: CGSize) -> MemoryCheckResult
}

// MARK: - Default Implementation

extension ObjectRemovalServiceProtocol {
    func removeObjects(from image: UIImage, mask: UIImage) async throws -> RemovalResult {
        try await removeObjects(from: image, mask: mask, progress: { _ in })
    }
}
