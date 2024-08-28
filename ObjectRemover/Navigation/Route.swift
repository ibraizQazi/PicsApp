//
//  Route.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 14/09/2023.
//

import Foundation
import SwiftUI

enum Route {
    case partialGallery
    case fullGallery
    case editor(data: ImageItem)
    case purchases(hideTabBar: Bool = false)
    case settings(hideTabBar: Bool = false)
    case share(data: Image, hideTabBar: Bool = false)
}

extension Route: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case(.partialGallery, .partialGallery):
            return true
        case (.fullGallery, .fullGallery):
            return true
        case (.editor(data: let lhsItem), .editor(data: let rhsItem)):
            return lhsItem.id == rhsItem.id
        case (.purchases, .purchases):
            return true
        case (.settings, .settings):
            return true
        case (.share(data: let lhsItem), .share(data: let rhsItem)):
            return lhsItem == rhsItem

        default:
            return false
        }
    }
}

extension Route: View {
    
    var body: some View {
        switch self {
            
        case .partialGallery:
//            PartialAccessGalleryGrid()
            EditorScreenView()
        case .fullGallery:
//            AllAccessGalleryGrid()
            EditorScreenView()
        case .editor(_):
            EditorView()
        case .purchases(let hideTabBar):
            IAPScreen()
                .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
        case .settings(let hideTabBar):
//            SettingsView()
            EmptyView()
                .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
        case .share(let data, let hideTabBar):
            ShareScreenView()
                .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
            
        }
    }
}

