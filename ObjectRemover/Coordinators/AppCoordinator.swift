//
//  AppCoordinator.swift
//  ObjectRemover
//
//  Root coordinator managing app navigation.
//

import SwiftUI
import Combine
import Photos

// MARK: - App Route

enum AppRoute: Hashable, Identifiable {
    case splash
    case home
    case editor(asset: PhotoAsset)
    case share(imageData: Data)  // Using Data instead of UIImage for Hashable
    case iap

    var id: String {
        switch self {
        case .splash: return "splash"
        case .home: return "home"
        case .editor(let asset): return "editor-\(asset.id)"
        case .share: return "share"
        case .iap: return "iap"
        }
    }

    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - App Coordinator

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Published State

    @Published private(set) var rootRoute: AppRoute = .splash
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppRoute?
    @Published var presentedFullScreen: AppRoute?

    // MARK: - Child Coordinators

    @Published private(set) var homeCoordinator: HomeCoordinator?
    @Published private(set) var editorCoordinator: EditorCoordinator?
    @Published private(set) var shareCoordinator: ShareCoordinator?

    // MARK: - Dependencies

    let dependencyContainer: DependencyContainer

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }

    // MARK: - Navigation

    func start() {
        rootRoute = .splash
    }

    func splashCompleted() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rootRoute = .home
        }
        createHomeCoordinator()
    }

    private func createHomeCoordinator() {
        homeCoordinator = HomeCoordinator(
            dependencyContainer: dependencyContainer,
            onImageSelected: { [weak self] asset in
                self?.navigateToEditor(with: asset)
            },
            onPurchaseTapped: { [weak self] in
                self?.presentIAP()
            }
        )
    }

    func navigateToEditor(with asset: PhotoAsset) {
        editorCoordinator = EditorCoordinator(
            asset: asset,
            dependencyContainer: dependencyContainer,
            onSave: { [weak self] image in
                self?.navigateToShare(image: image)
            },
            onDismiss: { [weak self] in
                self?.dismissEditor()
            }
        )
        navigationPath.append(AppRoute.editor(asset: asset))
    }

    func navigateToShare(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }

        shareCoordinator = ShareCoordinator(
            image: image,
            dependencyContainer: dependencyContainer,
            onDismiss: { [weak self] in
                self?.dismissShare()
            }
        )
        presentedFullScreen = .share(imageData: imageData)
    }

    func presentIAP() {
        presentedSheet = .iap
    }

    func dismissIAP() {
        presentedSheet = nil
    }

    private func dismissEditor() {
        editorCoordinator = nil
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    private func dismissShare() {
        shareCoordinator = nil
        presentedFullScreen = nil
        // Also pop back to home
        navigationPath = NavigationPath()
        editorCoordinator = nil
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
            editorCoordinator = nil
        }
    }

    func navigateToRoot() {
        navigationPath = NavigationPath()
        editorCoordinator = nil
        shareCoordinator = nil
        presentedFullScreen = nil
        presentedSheet = nil
    }
}
