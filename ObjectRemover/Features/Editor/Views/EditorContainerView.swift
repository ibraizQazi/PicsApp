//
//  EditorContainerView.swift
//  ObjectRemover
//
//  Main editor view container that integrates with EditorCoordinator.
//  Contains canvas, toolbar, and processing overlay.
//

import SwiftUI
import Photos

struct EditorContainerView: View {
    let asset: PhotoAsset
    @EnvironmentObject var coordinator: EditorCoordinator
    @StateObject private var viewModel: EditorViewModel

    @State private var image: UIImage?
    @State private var isLoadingImage = true
    @State private var loadError: String?

    init(asset: PhotoAsset) {
        self.asset = asset
        // ViewModel will be properly initialized after coordinator is available
        _viewModel = StateObject(wrappedValue: EditorViewModel())
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()

            if isLoadingImage {
                loadingView
            } else if let error = loadError {
                errorView(message: error)
            } else if let image = image {
                editorContent(image: image)
            }

            // Processing overlay
            if coordinator.isProcessing {
                processingOverlay
            }

            // Memory warning
            if coordinator.showingMemoryWarning {
                memoryWarningOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: coordinator.dismiss) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("EDITOR")
                    .font(.custom("Gilroy-Bold", size: 14))
                    .tracking(0.3)
                    .foregroundColor(.white)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveImage) {
                    Text("Save")
                        .font(.custom("Gilroy-Bold", size: 14))
                        .foregroundColor(.white)
                }
                .disabled(coordinator.isProcessing)
            }
        }
        .onAppear {
            loadImage()
        }
        .alert("Error", isPresented: .constant(coordinator.errorMessage != nil)) {
            Button("OK") { coordinator.dismissError() }
        } message: {
            Text(coordinator.errorMessage ?? "")
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Loading image...")
                .font(.custom("Gilroy-Medium", size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text(message)
                .font(.custom("Gilroy-Medium", size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: coordinator.dismiss) {
                Text("Go Back")
                    .font(.custom("Gilroy-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
    }

    // MARK: - Editor Content

    private func editorContent(image: UIImage) -> some View {
        VStack(spacing: 0) {
            // Canvas area
            EditorCanvasView(
                image: image,
                viewModel: viewModel,
                selectedTool: coordinator.selectedTool,
                brushSettings: coordinator.brushSettings
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Toolbar
            EditorToolbarView(
                selectedTool: coordinator.selectedTool,
                brushSize: coordinator.brushSettings.size,
                onToolSelected: coordinator.selectTool,
                onBrushSizeChanged: coordinator.updateBrushSize,
                onUndoTapped: viewModel.undo,
                onRedoTapped: viewModel.redo,
                onCompareTapped: coordinator.toggleCompareMode,
                onRemoveTapped: { performRemoval(image: image) },
                canUndo: viewModel.canUndo,
                canRedo: viewModel.canRedo
            )

            // Ad banner placeholder
            AdBannerPlaceholderView()
        }
    }

    // MARK: - Processing Overlay

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView(value: coordinator.processingProgress)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)

                Text("\(Int(coordinator.processingProgress * 100))%")
                    .font(.custom("Gilroy-Bold", size: 24))
                    .foregroundColor(.white)

                Text("Removing objects...")
                    .font(.custom("Gilroy-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.7))

                Button(action: coordinator.cancelProcessing) {
                    Text("Cancel")
                        .font(.custom("Gilroy-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(20)
                }
                .padding(.top, 10)
            }
        }
    }

    // MARK: - Memory Warning Overlay

    private var memoryWarningOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)

                Text("Insufficient Memory")
                    .font(.custom("Gilroy-Bold", size: 20))
                    .foregroundColor(.white)

                if let result = coordinator.memoryWarningResult {
                    Text("This image requires \(Int(result.requiredMemoryMB))MB but only \(Int(result.availableMemoryMB))MB is available.")
                        .font(.custom("Gilroy-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(spacing: 12) {
                        Button(action: {
                            coordinator.dismissMemoryWarning()
                            processAtScale(result.recommendedScale, image: image!)
                        }) {
                            Text("Process at \(Int(result.recommendedScale * 100))% Resolution")
                                .font(.custom("Gilroy-Bold", size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }

                        Button(action: coordinator.dismissMemoryWarning) {
                            Text("Cancel")
                                .font(.custom("Gilroy-Bold", size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                }
            }
        }
    }

    // MARK: - Actions

    private func loadImage() {
        guard let phAsset = asset.phAsset else {
            loadError = "Image not found"
            isLoadingImage = false
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        let size = CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight)

        PHImageManager.default().requestImage(
            for: phAsset,
            targetSize: size,
            contentMode: .aspectFit,
            options: options
        ) { loadedImage, info in
            if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                return
            }

            DispatchQueue.main.async {
                if let loadedImage = loadedImage {
                    self.image = loadedImage
                    self.viewModel.setOriginalImage(loadedImage)
                } else {
                    self.loadError = "Failed to load image"
                }
                self.isLoadingImage = false
            }
        }
    }

    private func performRemoval(image: UIImage) {
        guard let mask = viewModel.generateMask(for: image.size) else {
            coordinator.errorMessage = "No mask drawn"
            return
        }

        Task {
            do {
                let result = try await coordinator.performObjectRemoval(image: image, mask: mask)
                viewModel.applyRemovalResult(result)
            } catch {
                // Error already handled by coordinator
            }
        }
    }

    private func processAtScale(_ scale: CGFloat, image: UIImage) {
        guard let mask = viewModel.generateMask(for: image.size) else {
            coordinator.errorMessage = "No mask drawn"
            return
        }

        Task {
            do {
                let result = try await coordinator.performObjectRemovalWithScale(
                    image: image,
                    mask: mask,
                    scale: scale
                )
                viewModel.applyRemovalResult(result)
            } catch {
                // Error already handled by coordinator
            }
        }
    }

    private func saveImage() {
        guard let currentImage = viewModel.currentImage else { return }
        Task {
            await coordinator.saveImage(currentImage)
        }
    }
}

// MARK: - Ad Banner Placeholder

private struct AdBannerPlaceholderView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))

            HStack {
                Image(systemName: "megaphone.fill")
                    .foregroundColor(.gray)
                Text("Ad Placeholder")
                    .font(.custom("Gilroy-Medium", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 60)
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let coordinator = EditorCoordinator(
        asset: PhotoAsset(identifier: "test"),
        dependencyContainer: container,
        onSave: { _ in },
        onDismiss: {}
    )
    return NavigationStack {
        EditorContainerView(asset: PhotoAsset(identifier: "test"))
            .environmentObject(coordinator)
    }
}
