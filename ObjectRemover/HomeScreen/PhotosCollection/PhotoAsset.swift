//
//  PhotoAsset.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 10/03/2023.
//


import Photos
import os.log

struct PhotoAsset: Identifiable, Codable {
    var id: String { identifier }
    var identifier: String = UUID().uuidString
    var index: Int?
    var phAsset: PHAsset?
    
    typealias MediaType = PHAssetMediaType
    
    var isFavorite: Bool {
        phAsset?.isFavorite ?? false
    }
    
    var mediaType: MediaType {
        phAsset?.mediaType ?? .unknown
    }
    
    var accessibilityLabel: String {
        "Photo"
    }
    
    init(phAsset: PHAsset, index: Int?) {
        self.phAsset = phAsset
        self.index = index
        self.identifier = phAsset.localIdentifier
    }
    
    init(identifier: String) {
        self.identifier = identifier
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        self.phAsset = fetchedAssets.firstObject
    }
    
    func setIsFavorite(_ isFavorite: Bool) async {
        guard let phAsset = phAsset else { return }
        Task {
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetChangeRequest(for: phAsset)
                    request.isFavorite = isFavorite
                }
            } catch (let error) {
                logger.error("Failed to change isFavorite: \(error.localizedDescription)")
            }
        }
    }
    
    func delete() async {
        guard let phAsset = phAsset else { return }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets([phAsset] as NSArray)
            }
            logger.debug("PhotoAsset asset deleted: \(index ?? -1)")
        } catch (let error) {
            logger.error("Failed to delete photo: \(error.localizedDescription)")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier, index, isFavorite, mediaType, accessibilityLabel
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.index = try container.decodeIfPresent(Int.self, forKey: .index)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(index, forKey: .index)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(mediaType.rawValue, forKey: .mediaType)
        try container.encode(accessibilityLabel, forKey: .accessibilityLabel)
    }
}

extension PhotoAsset: Equatable {
    static func ==(lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        (lhs.identifier == rhs.identifier) && (lhs.isFavorite == rhs.isFavorite)
    }
}

extension PhotoAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension PHObject: Identifiable {
    public var id: String { localIdentifier }
}

fileprivate let logger = Logger(subsystem: "com.trinium.ai.snaperaser", category: "PhotoAsset")

