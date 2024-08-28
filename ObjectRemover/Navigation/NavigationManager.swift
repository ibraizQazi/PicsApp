//
//  NavigationManager.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 18/04/2023.
//

import Foundation
import Combine

enum EditorState: Hashable, Codable {
    case remover(PhotoAsset)
    case cloner(PhotoAsset)
    case save
    case purchase
}

@Observable class NavigationStateManager {
    
    var editorPath = [EditorState]()
    
    var data: Data? {
        get {
            try? JSONEncoder().encode(editorPath)
        }
        
        set {
            guard let data = newValue,
                  let path =  try? JSONDecoder().decode([EditorState].self, from: data) else {
                return
            }
            self.editorPath = path
        }
    }
    
    func popToHome() {
        editorPath = []
    }
    
    
    func goToGallery() {
//        editorPath.append(EditorState.gallery)
        editorPath = []
    }
    
    
    func goToPurchase() {
        editorPath.append(EditorState.purchase)
    }
    
//    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
//        objectWillChange
//            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
//            .values
//    }
}
