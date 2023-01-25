//
//  Photo.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 07/01/2023.
//

import Foundation
import SwiftUI


struct PhotoItem: Identifiable {
    var id = UUID()
    var image: Image
    
    init(id: UUID = UUID(), image: Image) {
        self.id = id
        self.image = image
    }
}

extension PhotoItem {
    static let sampleData: [PhotoItem] = [
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
        PhotoItem(image: Image("placeholder-image")),
    ]
}
