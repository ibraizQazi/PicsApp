//
//  AllAccessViewModel.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 05/02/2023.
//

import Foundation
import Photos


class AllAccessViewModel: ObservableObject {
    enum State: Comparable {
        case good
        case isLoading
        case loadedAll
        case showPreview
        case error(String)
    }
    
    @Published var state: State = .good {
        didSet {
            print("state changed to: \(state)")
        }
    }
    
    var isStateGood: Bool {
        state == .good
    }
    
    var isStateLoading: Bool {
        state == .isLoading
    }
    
    var toShowPreview: Bool {
        state == .showPreview
    }
    
    @Published var items: [ImageItem] = [ImageItem]()
    
    @Published var errorString : String = ""
    
    @Published var selectedPhoto: ImageItem? = nil
    
    var imageCachingManager = PHCachingImageManager()
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var totalPhotos: Int = 0
    var lastindex: Int = 0
    
    init() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            self.authorizationStatus = status
            switch status {
            case .authorized:
                self.errorString = ""
                self.fetchFirstPhotos()
            case .limited, .restricted, .notDetermined:
                if let documentDirectory = FileManager.default.documentDirectory {
                    let urls = FileManager.default.getContentsOfDirectory(documentDirectory).filter { $0.isImage }
                    for url in urls {
                        let item = ImageItem(url: url)
                        self.items.append(item)
                    }
                }
            case .denied:
                self.errorString = "Photo access permission denied"
                //            case .notDetermined:
                //                self.errorString = "Photo access permission not determined"
            @unknown default:
                fatalError()
            }
        }
        
        //        if let documentDirectory = FileManager.default.documentDirectory {
        //            let urls = FileManager.default.getContentsOfDirectory(documentDirectory).filter { $0.isImage }
        //            for url in urls {
        //                let item = ImageItem(url: url)
        //                items.append(item)
        //            }
        //        }
        
        
        //        if let urls = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: nil) {
        //            for url in urls {
        //                let item = ImageItem(url: url)
        //                items.append(item)
        //            }
        //        }
    }
    
    func setSelectedPhoto(imageItem: ImageItem) {
        selectedPhoto = imageItem
        self.state = .showPreview
    }
    
    
    func hasReachedEnd(imageItem: ImageItem) -> Bool {
        items.last?.id == imageItem.id
    }
    
    func fetchMorePhotos() {
        
        print("fetchMorePhotos")
        
        guard state == State.good else {
            return
        }
        
        guard self.lastindex < self.totalPhotos else {
            return
        }
        
        state = .isLoading
        var tempPhotos: [ImageItem] = []
        
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        DispatchQueue.global().async {
            let photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            for index in self.lastindex...(self.lastindex + 10) {
                var asset = photos.object(at: index)
                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                    if let input = eidtingInput, let photoUrl = input.fullSizeImageURL {
                        let photo = ImageItem(url: photoUrl)
                        tempPhotos.append(photo)
                    }
                }
            }
            
            self.lastindex += 10
            
        }
        
        DispatchQueue.main.async {
            self.items.append(contentsOf: tempPhotos)
        }
    }
    
    func fetchFirstPhotos() {
        print("fetchAllPhotos called")
        
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]

//        var tempPhotos = [ImageItem]()
        
        DispatchQueue.global().async {
            let photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)

//            self.totalPhotos = photos.count
//
//            for index in 0...10 {
//                var asset = photos.object(at: index)
//
//                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
//                    if let input = eidtingInput, let photoUrl = input.fullSizeImageURL {
//                        let photo = ImageItem(url: photoUrl)
//                        tempPhotos.append(photo)
//                    }
//                }
//
//            }
            photos.enumerateObjects({asset, _, index in

                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                    if let input = eidtingInput, let photoUrl = input.fullSizeImageURL {
                        let photo = ImageItem(url: photoUrl)
                        self.items.append(photo)
                    }
                }
                
            })
        }
        
//      Update main thread and UI
//        DispatchQueue.main.async {
//
//            tempPhotos.removeAll()
//
//            self.items = tempPhotos
//        }

    }
    
    /// Adds an item to the data collection.
    func addItem(item: ImageItem) {
        if items.isEmpty {
            items.append(item)
        } else {
            items.insert(item, at: 1)
        }
    }
    
    /// Removes an item from the data collection.
    func removeItem(item: ImageItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            FileManager.default.removeItemFromDocumentDirectory(url: item.url)
        }
    }
}
