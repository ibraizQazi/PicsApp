//
//  DummyIAPService.swift
//  ObjectRemover
//
//  Dummy implementation of IAP service for development/testing.
//  Replace with StoreKit 2 or RevenueCat implementation in production.
//

import Foundation
import Combine

final class DummyIAPService: IAPServiceProtocol {

    // MARK: - Published State

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var products: [IAPProduct] = []
    @Published private(set) var isLoading: Bool = false

    var isPremiumPublisher: AnyPublisher<Bool, Never> {
        $isPremium.eraseToAnyPublisher()
    }

    var productsPublisher: AnyPublisher<[IAPProduct], Never> {
        $products.eraseToAnyPublisher()
    }

    // MARK: - Private State

    private let userDefaultsKey = "com.snaperaser.isPremium"

    // MARK: - Initialization

    init() {
        // Load premium status from UserDefaults
        isPremium = UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    // MARK: - IAPServiceProtocol

    func loadProducts() async throws {
        isLoading = true

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Create dummy products
        products = [
            IAPProduct(
                type: .weekly,
                price: 4.99,
                priceString: "$4.99",
                currencyCode: "USD",
                savingsPercent: nil,
                isPopular: false
            ),
            IAPProduct(
                type: .monthly,
                price: 9.99,
                priceString: "$9.99",
                currencyCode: "USD",
                savingsPercent: 50,
                isPopular: false
            ),
            IAPProduct(
                type: .lifetime,
                price: 29.99,
                priceString: "$29.99",
                currencyCode: "USD",
                savingsPercent: 85,
                isPopular: true
            )
        ]

        isLoading = false
    }

    func purchase(_ product: IAPProduct) async -> PurchaseResult {
        // Simulate purchase delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Simulate successful purchase
        await MainActor.run {
            isPremium = true
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
        }

        return .success(productId: product.id)
    }

    func restorePurchases() async throws -> Bool {
        // Simulate restore delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // For dummy implementation, just check UserDefaults
        let restored = UserDefaults.standard.bool(forKey: userDefaultsKey)

        await MainActor.run {
            isPremium = restored
        }

        return restored
    }

    func checkEntitlement() async -> Bool {
        return isPremium
    }

    func getRecommendedProduct() -> IAPProduct? {
        products.first { $0.isPopular } ?? products.last
    }

    // MARK: - Debug Methods

    #if DEBUG
    func resetPremiumStatus() {
        isPremium = false
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
    }

    func grantPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
    #endif
}
