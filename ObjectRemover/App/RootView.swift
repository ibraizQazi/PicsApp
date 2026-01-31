//
//  RootView.swift
//  ObjectRemover
//
//  Root view that manages navigation based on AppCoordinator state.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            sheetView(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            fullScreenView(for: route)
        }
    }

    // MARK: - Root Content

    @ViewBuilder
    private var rootContent: some View {
        switch coordinator.rootRoute {
        case .splash:
            SplashView(onComplete: coordinator.splashCompleted)
        case .home:
            if let homeCoordinator = coordinator.homeCoordinator {
                HomeContainerView()
                    .environmentObject(homeCoordinator)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Navigation Destinations

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .editor(let asset):
            if let editorCoordinator = coordinator.editorCoordinator {
                EditorContainerView(asset: asset)
                    .environmentObject(editorCoordinator)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Sheet Views

    @ViewBuilder
    private func sheetView(for route: AppRoute) -> some View {
        switch route {
        case .iap:
            IAPScreen()
        default:
            EmptyView()
        }
    }

    // MARK: - Full Screen Cover Views

    @ViewBuilder
    private func fullScreenView(for route: AppRoute) -> some View {
        switch route {
        case .share:
            if let shareCoordinator = coordinator.shareCoordinator {
                ShareContainerView()
                    .environmentObject(shareCoordinator)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let coordinator = AppCoordinator(dependencyContainer: container)
    return RootView()
        .environmentObject(coordinator)
}
