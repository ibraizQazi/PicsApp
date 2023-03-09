//
//  ImageItem.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 30/01/2023.
//

import SwiftUI

struct ImageItem: Identifiable {
    
    let id = UUID()
    let url: URL
    
}

extension ImageItem: Equatable {
    static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}


