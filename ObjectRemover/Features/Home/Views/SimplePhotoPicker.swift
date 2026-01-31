//
//  SimplePhotoPicker.swift
//  ObjectRemover
//
//  A simple photo picker that returns a PhotoAsset via callback.
//

import SwiftUI
import PhotosUI

struct SimplePhotoPicker: UIViewControllerRepresentable {
    let onPicked: (PhotoAsset) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: SimplePhotoPicker

        init(_ parent: SimplePhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first,
                  let assetIdentifier = result.assetIdentifier else {
                return
            }

            // Fetch the PHAsset
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            guard let phAsset = fetchResult.firstObject else { return }

            let photoAsset = PhotoAsset(phAsset: phAsset, index: nil)
            parent.onPicked(photoAsset)
        }
    }
}
