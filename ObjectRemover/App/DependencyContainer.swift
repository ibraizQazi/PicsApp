//
//  DependencyContainer.swift
//  ObjectRemover
//
//  Dependency injection container for managing service instances.
//

import Foundation
import SwiftUI

/// Container for all app dependencies
/// Use this to inject services into coordinators and view models
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Services

    /// Object removal service (dummy implementation, replaceable with ML/API)
    lazy var objectRemovalService: ObjectRemovalServiceProtocol = {
        DummyObjectRemovalService()
    }()

    /// Ad service (dummy implementation for now)
    lazy var adService: AdServiceProtocol = {
        DummyAdService()
    }()

    /// Image repository for loading/saving images
    lazy var imageRepository: ImageRepositoryProtocol = {
        DefaultImageRepository()
    }()

    /// In-App Purchase service (dummy implementation, replaceable with StoreKit/RevenueCat)
    lazy var iapService: IAPServiceProtocol = {
        DummyIAPService()
    }()

    // MARK: - Initialization

    init() {
        // Initialize any services that need setup
        Task {
            await adService.initialize()
        }
    }
}

// MARK: - Environment Key

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencyContainer: DependencyContainer? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
