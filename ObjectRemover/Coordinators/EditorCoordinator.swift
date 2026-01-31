//
//  EditorCoordinator.swift
//  ObjectRemover
//
//  Coordinator for the editor screen.
//

import SwiftUI
import Combine
import Photos

@MainActor
final class EditorCoordinator: ObservableObject {

    // MARK: - Published State

    @Published var selectedTool: EditorTool = .brush
    @Published var brushSettings = BrushSettings()
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0
    @Published var showingMemoryWarning = false
    @Published var memoryWarningResult: MemoryCheckResult?
    @Published var showingCompareMode = false
    @Published var errorMessage: String?

    // MARK: - Asset

    let asset: PhotoAsset

    // MARK: - Dependencies

    let dependencyContainer: DependencyContainer

    // MARK: - Services

    private var objectRemovalService: ObjectRemovalServiceProtocol {
        dependencyContainer.objectRemovalService
    }

    private var imageRepository: ImageRepositoryProtocol {
        dependencyContainer.imageRepository
    }

    // MARK: - Callbacks

    private let onSave: (UIImage) -> Void
    private let onDismiss: () -> Void

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        asset: PhotoAsset,
        dependencyContainer: DependencyContainer,
        onSave: @escaping (UIImage) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.asset = asset
        self.dependencyContainer = dependencyContainer
        self.onSave = onSave
        self.onDismiss = onDismiss
    }

    // MARK: - Tool Selection

    func selectTool(_ tool: EditorTool) {
        selectedTool = tool
    }

    // MARK: - Brush Settings

    func updateBrushSize(_ size: CGFloat) {
        brushSettings.size = size
    }

    func updateBrushOpacity(_ opacity: CGFloat) {
        brushSettings.opacity = opacity
    }

    func updateBrushHardness(_ hardness: CGFloat) {
        brushSettings.hardness = hardness
    }

    // MARK: - Object Removal

    func performObjectRemoval(image: UIImage, mask: UIImage) async throws -> UIImage {
        // Check memory first
        let memoryCheck = objectRemovalService.canProcess(imageSize: image.size)
        if !memoryCheck.canProcess {
            memoryWarningResult = memoryCheck
            showingMemoryWarning = true
            throw ObjectRemovalError.insufficientMemory(
                required: memoryCheck.requiredMemoryMB,
                available: memoryCheck.availableMemoryMB
            )
        }

        isProcessing = true
        processingProgress = 0

        do {
            let result = try await objectRemovalService.removeObjects(
                from: image,
                mask: mask,
                progress: { [weak self] progress in
                    Task { @MainActor in
                        self?.processingProgress = progress
                    }
                }
            )
            isProcessing = false
            return result.processedImage
        } catch {
            isProcessing = false
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func performObjectRemovalWithScale(
        image: UIImage,
        mask: UIImage,
        scale: CGFloat
    ) async throws -> UIImage {
        // Scale down the image
        let scaledImage = imageRepository.scaleImageForProcessing(image, recommendedScale: scale)
        let scaledMask = imageRepository.scaleImageForProcessing(mask, recommendedScale: scale)

        // Process at lower resolution
        let processedImage = try await performObjectRemoval(image: scaledImage, mask: scaledMask)

        // Upscale back to original resolution
        return imageRepository.upscaleToOriginal(processedImage: processedImage, originalSize: image.size)
    }

    func cancelProcessing() {
        objectRemovalService.cancelProcessing()
        isProcessing = false
    }

    // MARK: - Compare Mode

    func toggleCompareMode() {
        showingCompareMode.toggle()
    }

    // MARK: - Save

    func saveImage(_ image: UIImage) async {
        do {
            try await imageRepository.saveToPhotosLibrary(image)
            onSave(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func shareImage(_ image: UIImage) {
        onSave(image)
    }

    // MARK: - Dismiss

    func dismiss() {
        if isProcessing {
            cancelProcessing()
        }
        onDismiss()
    }

    func dismissMemoryWarning() {
        showingMemoryWarning = false
        memoryWarningResult = nil
    }

    func dismissError() {
        errorMessage = nil
    }
}
