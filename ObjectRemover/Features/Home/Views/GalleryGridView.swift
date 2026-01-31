//
//  GalleryGridView.swift
//  ObjectRemover
//
//  Grid view displaying photos from the user's library.
//

import SwiftUI
import Photos

struct GalleryGridView: View {
    @ObservedObject var photosCollection: PhotoCollection
    let isLimitedAccess: Bool
    let onPhotoSelected: (PhotoAsset) -> Void
    let onAddTapped: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        VStack(spacing: 0) {
            if isLimitedAccess {
                limitedAccessBanner
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    // Add photo button
                    AddPhotoCell(onTap: onAddTapped)

                    // Photo cells
                    ForEach(photosCollection.photoAssets) { asset in
                        PhotoCell(asset: asset)
                            .onTapGesture {
                                onPhotoSelected(asset)
                            }
                    }
                }
                .padding(.horizontal, 2)
            }

            // Ad banner placeholder
            AdBannerPlaceholder()
        }
    }

    private var limitedAccessBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)

            Text("Limited access - Tap to manage photos")
                .font(.custom("Gilroy-Medium", size: 12))
                .foregroundColor(.gray)

            Spacer()

            Button(action: openLimitedLibraryPicker) {
                Text("Manage")
                    .font(.custom("Gilroy-Bold", size: 12))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
    }

    private func openLimitedLibraryPicker() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            return
        }
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
    }
}

// MARK: - Add Photo Cell

private struct AddPhotoCell: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))

                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)

                    Text("Add")
                        .font(.custom("Gilroy-Medium", size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Photo Cell

private struct PhotoCell: View {
    let asset: PhotoAsset
    @StateObject private var imageLoader = PhotoImageLoader()

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))

            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .onAppear {
            imageLoader.load(asset: asset)
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

// MARK: - Photo Image Loader

private class PhotoImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var requestID: PHImageRequestID?
    private let imageManager = PHCachingImageManager()

    func load(asset: PhotoAsset) {
        guard let phAsset = asset.phAsset else { return }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast

        let size = CGSize(width: 200, height: 200)

        requestID = imageManager.requestImage(
            for: phAsset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }

    func cancel() {
        if let requestID = requestID {
            imageManager.cancelImageRequest(requestID)
        }
    }
}

// MARK: - Ad Banner Placeholder

private struct AdBannerPlaceholder: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))

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
    GalleryGridView(
        photosCollection: PhotoCollection(smartAlbum: .smartAlbumUserLibrary),
        isLimitedAccess: false,
        onPhotoSelected: { _ in },
        onAddTapped: {}
    )
}
