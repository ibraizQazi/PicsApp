//
//  HomeCoordinator.swift
//  ObjectRemover
//
//  Coordinator for the home/gallery screen.
//

import SwiftUI
import Combine
import Photos

@MainActor
final class HomeCoordinator: ObservableObject {

    // MARK: - Published State

    @Published var selectedAsset: PhotoAsset?
    @Published var showingPreviewSheet = false
    @Published var showingPhotoPicker = false
    @Published var photoPermission: PHAuthorizationStatus = .notDetermined

    // MARK: - Dependencies

    let dependencyContainer: DependencyContainer

    // MARK: - Callbacks

    private let onImageSelected: (PhotoAsset) -> Void
    private let onPurchaseTapped: () -> Void

    // MARK: - Initialization

    init(
        dependencyContainer: DependencyContainer,
        onImageSelected: @escaping (PhotoAsset) -> Void,
        onPurchaseTapped: @escaping () -> Void
    ) {
        self.dependencyContainer = dependencyContainer
        self.onImageSelected = onImageSelected
        self.onPurchaseTapped = onPurchaseTapped

        checkPhotoPermission()
    }

    // MARK: - Permission Handling

    func checkPhotoPermission() {
        photoPermission = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestPhotoPermission() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            photoPermission = status
        }
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    // MARK: - Photo Selection

    func selectPhoto(_ asset: PhotoAsset) {
        selectedAsset = asset
        showingPreviewSheet = true
    }

    func confirmSelection() {
        guard let asset = selectedAsset else { return }
        showingPreviewSheet = false
        onImageSelected(asset)
    }

    func cancelSelection() {
        showingPreviewSheet = false
        selectedAsset = nil
    }

    func openPhotoPicker() {
        showingPhotoPicker = true
    }

    func handlePickedPhoto(_ asset: PhotoAsset) {
        showingPhotoPicker = false
        selectedAsset = asset
        onImageSelected(asset)
    }

    // MARK: - Purchase

    func openPurchase() {
        onPurchaseTapped()
    }
}
