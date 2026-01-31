//
//  PhotoPreviewSheet.swift
//  ObjectRemover
//
//  Sheet for previewing a selected photo before editing.
//

import SwiftUI
import Photos

struct PhotoPreviewSheet: View {
    let asset: PhotoAsset
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Failed to load image")
                            .font(.custom("Gilroy-Medium", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.05))
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        onConfirm()
                    }
                    .font(.custom("Gilroy-Bold", size: 16))
                    .disabled(image == nil)
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let phAsset = asset.phAsset else {
            isLoading = false
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        let size = CGSize(width: 1024, height: 1024)

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
                self.image = loadedImage
                self.isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PhotoPreviewSheet(
        asset: PhotoAsset(identifier: "test"),
        onConfirm: {},
        onCancel: {}
    )
}
