//
//  ShareCoordinator.swift
//  ObjectRemover
//
//  Coordinator for the share/save screen.
//

import SwiftUI
import Combine

@MainActor
final class ShareCoordinator: ObservableObject {

    // MARK: - Published State

    @Published var isSaving = false
    @Published var saveSuccess = false
    @Published var showingShareSheet = false
    @Published var errorMessage: String?

    // MARK: - Data

    let image: UIImage

    // MARK: - Dependencies

    let dependencyContainer: DependencyContainer

    private var imageRepository: ImageRepositoryProtocol {
        dependencyContainer.imageRepository
    }

    // MARK: - Callbacks

    private let onDismiss: () -> Void

    // MARK: - Initialization

    init(
        image: UIImage,
        dependencyContainer: DependencyContainer,
        onDismiss: @escaping () -> Void
    ) {
        self.image = image
        self.dependencyContainer = dependencyContainer
        self.onDismiss = onDismiss
    }

    // MARK: - Actions

    func saveToPhotos() async {
        isSaving = true
        do {
            try await imageRepository.saveToPhotosLibrary(image)
            saveSuccess = true
            isSaving = false
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }

    func showShareSheet() {
        showingShareSheet = true
    }

    func hideShareSheet() {
        showingShareSheet = false
    }

    func dismiss() {
        onDismiss()
    }

    func dismissError() {
        errorMessage = nil
    }
}
