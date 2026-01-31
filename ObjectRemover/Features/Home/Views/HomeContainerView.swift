//
//  HomeContainerView.swift
//  ObjectRemover
//
//  Container view for the home screen that integrates with HomeCoordinator.
//

import SwiftUI
import Photos

struct HomeContainerView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    @StateObject private var photosCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Main content based on permission status
                contentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("OBJECT REMOVER")
                    .font(.custom("Gilroy-Bold", size: 14))
                    .tracking(0.3)
                    .foregroundColor(.black)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: coordinator.openPurchase) {
                    Text("PRO")
                        .font(.custom("Gilroy-Bold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            coordinator.checkPhotoPermission()
            loadPhotosIfNeeded()
        }
        .sheet(isPresented: $coordinator.showingPreviewSheet) {
            if let asset = coordinator.selectedAsset {
                PhotoPreviewSheet(
                    asset: asset,
                    onConfirm: coordinator.confirmSelection,
                    onCancel: coordinator.cancelSelection
                )
            }
        }
        .sheet(isPresented: $coordinator.showingPhotoPicker) {
            SimplePhotoPicker { asset in
                coordinator.handlePickedPhoto(asset)
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        switch coordinator.photoPermission {
        case .notDetermined:
            permissionRequestView

        case .denied, .restricted:
            deniedAccessView

        case .limited:
            GalleryGridView(
                photosCollection: photosCollection,
                isLimitedAccess: true,
                onPhotoSelected: coordinator.selectPhoto,
                onAddTapped: coordinator.openPhotoPicker
            )

        case .authorized:
            GalleryGridView(
                photosCollection: photosCollection,
                isLimitedAccess: false,
                onPhotoSelected: coordinator.selectPhoto,
                onAddTapped: coordinator.openPhotoPicker
            )

        @unknown default:
            permissionRequestView
        }
    }

    // MARK: - Permission Views

    private var permissionRequestView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Photo Library Access")
                .font(.custom("Gilroy-Bold", size: 20))
                .foregroundColor(.black)

            Text("We need access to your photo library to help you remove objects from your photos.")
                .font(.custom("Gilroy-Medium", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                Task {
                    await coordinator.requestPhotoPermission()
                    loadPhotosIfNeeded()
                }
            }) {
                Text("Give Access")
                    .font(.custom("Gilroy-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.top, 10)

            Spacer()
        }
    }

    private var deniedAccessView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Access Denied")
                .font(.custom("Gilroy-Bold", size: 20))
                .foregroundColor(.black)

            Text("Please enable photo library access in Settings to use this app.")
                .font(.custom("Gilroy-Medium", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: coordinator.openSettings) {
                Text("Open Settings")
                    .font(.custom("Gilroy-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.top, 10)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func loadPhotosIfNeeded() {
        Task {
            if coordinator.photoPermission == .authorized {
                await photosCollection.loadPhotos(smartAlbum: .smartAlbumUserLibrary)
            } else if coordinator.photoPermission == .limited {
                await photosCollection.loadPhotos(smartAlbum: .smartAlbumRecentlyAdded)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let coordinator = HomeCoordinator(
        dependencyContainer: container,
        onImageSelected: { _ in },
        onPurchaseTapped: {}
    )
    return NavigationStack {
        HomeContainerView()
            .environmentObject(coordinator)
    }
}
