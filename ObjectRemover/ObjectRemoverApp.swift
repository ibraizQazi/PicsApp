//
//  ObjectRemoverApp.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 15/12/2022.
//

import SwiftUI

@main
struct ObjectRemoverApp: App {

    @StateObject private var dependencyContainer: DependencyContainer
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let container = DependencyContainer()
        _dependencyContainer = StateObject(wrappedValue: container)
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(dependencyContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appCoordinator)
                .environment(\.dependencyContainer, dependencyContainer)
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
}
