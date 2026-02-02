//
//  IAPCoordinator.swift
//  ObjectRemover
//
//  Coordinator for the In-App Purchase screen.
//

import SwiftUI
import Combine

@MainActor
final class IAPCoordinator: ObservableObject {

    // MARK: - Published State

    @Published private(set) var products: [IAPProduct] = []
    @Published var selectedProduct: IAPProduct?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var isRestoring: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var purchaseSuccess: Bool = false

    // MARK: - Dependencies

    let dependencyContainer: DependencyContainer

    private var iapService: IAPServiceProtocol {
        dependencyContainer.iapService
    }

    // MARK: - Callbacks

    private let onDismiss: () -> Void
    private let onPurchaseComplete: () -> Void

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        dependencyContainer: DependencyContainer,
        onDismiss: @escaping () -> Void,
        onPurchaseComplete: @escaping () -> Void
    ) {
        self.dependencyContainer = dependencyContainer
        self.onDismiss = onDismiss
        self.onPurchaseComplete = onPurchaseComplete

        setupBindings()
    }

    private func setupBindings() {
        iapService.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.products = products
                // Auto-select recommended product
                if self?.selectedProduct == nil {
                    self?.selectedProduct = self?.iapService.getRecommendedProduct()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func loadProducts() {
        guard !isLoading else { return }

        isLoading = true
        Task {
            do {
                try await iapService.loadProducts()
                isLoading = false
            } catch {
                isLoading = false
                showError(message: error.localizedDescription)
            }
        }
    }

    func selectProduct(_ product: IAPProduct) {
        selectedProduct = product
    }

    func purchase() {
        guard let product = selectedProduct else {
            showError(message: "Please select a subscription plan")
            return
        }

        isPurchasing = true
        Task {
            let result = await iapService.purchase(product)

            await MainActor.run {
                isPurchasing = false

                switch result {
                case .success:
                    purchaseSuccess = true
                    // Notify that premium status changed
                    dependencyContainer.adService.setPremiumStatus(true)
                    onPurchaseComplete()
                case .pending:
                    showError(message: "Purchase is pending approval")
                case .cancelled:
                    // User cancelled, no error needed
                    break
                case .failed(let error):
                    showError(message: error.localizedDescription)
                }
            }
        }
    }

    func restore() {
        isRestoring = true
        Task {
            do {
                let restored = try await iapService.restorePurchases()

                await MainActor.run {
                    isRestoring = false

                    if restored {
                        purchaseSuccess = true
                        dependencyContainer.adService.setPremiumStatus(true)
                        onPurchaseComplete()
                    } else {
                        showError(message: "No previous purchases found")
                    }
                }
            } catch {
                await MainActor.run {
                    isRestoring = false
                    showError(message: error.localizedDescription)
                }
            }
        }
    }

    func dismiss() {
        onDismiss()
    }

    func openTerms() {
        if let url = URL(string: "https://example.com/terms") {
            UIApplication.shared.open(url)
        }
    }

    func openPrivacy() {
        if let url = URL(string: "https://example.com/privacy") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Private Methods

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
