//
//  PhotoPicker.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 26/12/2022.
//

import SwiftUI
import PhotosUI


struct PhotoPicker: UIViewControllerRepresentable {
    
    @EnvironmentObject var dataModel: PhotosModel

    /// A dismiss action provided by the environment. This may be called to dismiss this view controller.
    @Environment(\.dismiss) var dismiss

    /// Creates the picker view controller that this object represents.
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {

        // Configure the picker.
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        // Limit to images.
        configuration.filter = .images
        // Avoid transcoding, if possible.
        configuration.preferredAssetRepresentationMode = .current

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }

    /// Creates the coordinator that allows the picker to communicate back to this object.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Updates the picker while it’s being presented.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoPicker>) {
        // No updates are necessary.
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    let parent: PhotoPicker

    /// Called when one or more items have been picked, or when the picker has been canceled.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        // Dismisss the presented picker.
        self.parent.dismiss()

        guard
            let result = results.first,
            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else { return }

        // Load a file representation of the picked item.
        // This creates a temporary file which is then copied to the app’s document directory for persistent storage.
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
            if let error = error {
                print("Error loading file representation: \(error.localizedDescription)")
            } else if let url = url {
                if let savedUrl = FileManager.default.copyItemToDocumentDirectory(from: url) {
                    // Add the new item to the data model.
                    Task { @MainActor [dataModel = self.parent.dataModel] in
                        withAnimation {
                            let item = ImageItem(url: savedUrl)
                            dataModel.addItem(item: item)
                        }
                    }
                }
            }
        }
    }

    init(_ parent: PhotoPicker) {
        self.parent = parent
    }
}

//struct PhotoPicker: UIViewControllerRepresentable {
//    typealias UIViewControllerType = PHPickerViewController
//
//    let filter: PHPickerFilter
//    var limit: Int = 0 // 0 == 'no limit'.
//    let onComplete: ([PHPickerResult]) -> Void
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = filter
//        configuration.selectionLimit = limit
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = context.coordinator
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: PHPickerViewControllerDelegate {
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.onComplete(results)
//            picker.dismiss(animated: true)
//        }
//
//        private let parent: PhotoPicker
//
//        init(_ parent: PhotoPicker) {
//            self.parent = parent
//        }
//    }
//
//    static func convertToUIImageArray(fromResults results: [PHPickerResult], onComplete: @escaping ([UIImage]?, Error?) -> Void) {
//        var images = [UIImage]()
//
//        let dispatchGroup = DispatchGroup()
//
//        for result in results {
//            dispatchGroup.enter()
//            let itemProvider = result.itemProvider
//            if itemProvider.canLoadObject(ofClass: UIImage.self) {
//                itemProvider.loadObject(ofClass: UIImage.self) { (imageOrNil, errorOrNil) in
//                    if let error = errorOrNil {
//                        onComplete(nil, error)
//                        dispatchGroup.leave()
//                    }
//                    if let image = imageOrNil as? UIImage {
//                        images.append(image)
////                        images.insert(image, at: images.startIndex)
//
//                        dispatchGroup.leave()
//                    }
//                }
//            }
//        }
//        dispatchGroup.notify(queue: .main) {
//            onComplete(images, nil)
//        }
//    }
//}
