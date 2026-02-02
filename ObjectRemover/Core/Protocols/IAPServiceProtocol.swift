//
//  IAPServiceProtocol.swift
//  ObjectRemover
//
//  Protocol abstraction for In-App Purchase service.
//  Can be implemented with StoreKit 2, RevenueCat, or dummy implementation.
//

import Foundation
import Combine

// MARK: - Product Types

enum IAPProductType: String, CaseIterable, Identifiable {
    case weekly = "com.snaperaser.weekly"
    case monthly = "com.snaperaser.monthly"
    case lifetime = "com.snaperaser.lifetime"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return "WEEKLY"
        case .monthly: return "MONTHLY"
        case .lifetime: return "LIFETIME"
        }
    }

    var period: String {
        switch self {
        case .weekly: return "week"
        case .monthly: return "month"
        case .lifetime: return "once"
        }
    }

    var hasFreeTrial: Bool {
        switch self {
        case .weekly: return true
        case .monthly: return false
        case .lifetime: return false
        }
    }

    var trialDays: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 0
        case .lifetime: return 0
        }
    }
}

// MARK: - Product Info

struct IAPProduct: Identifiable, Equatable {
    let id: String
    let type: IAPProductType
    let price: Decimal
    let priceString: String
    let currencyCode: String
    var savingsPercent: Int?
    var isPopular: Bool

    init(
        type: IAPProductType,
        price: Decimal,
        priceString: String,
        currencyCode: String = "USD",
        savingsPercent: Int? = nil,
        isPopular: Bool = false
    ) {
        self.id = type.rawValue
        self.type = type
        self.price = price
        self.priceString = priceString
        self.currencyCode = currencyCode
        self.savingsPercent = savingsPercent
        self.isPopular = isPopular
    }
}

// MARK: - Purchase Result

enum PurchaseResult {
    case success(productId: String)
    case pending
    case cancelled
    case failed(Error)
}

// MARK: - IAP Errors

enum IAPError: Error, LocalizedError {
    case productsNotLoaded
    case productNotFound
    case purchaseFailed(underlying: Error?)
    case restoreFailed(underlying: Error?)
    case notEntitled
    case networkError

    var errorDescription: String? {
        switch self {
        case .productsNotLoaded:
            return "Products are not loaded yet"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error?.localizedDescription ?? "Unknown error")"
        case .restoreFailed(let error):
            return "Restore failed: \(error?.localizedDescription ?? "Unknown error")"
        case .notEntitled:
            return "You don't have an active subscription"
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}

// MARK: - Protocol

protocol IAPServiceProtocol: AnyObject {
    /// Whether the user has an active premium subscription
    var isPremium: Bool { get }

    /// Publisher for premium status changes
    var isPremiumPublisher: AnyPublisher<Bool, Never> { get }

    /// Available products
    var products: [IAPProduct] { get }

    /// Publisher for products
    var productsPublisher: AnyPublisher<[IAPProduct], Never> { get }

    /// Whether products are loading
    var isLoading: Bool { get }

    /// Load available products from the store
    func loadProducts() async throws

    /// Purchase a product
    func purchase(_ product: IAPProduct) async -> PurchaseResult

    /// Restore previous purchases
    func restorePurchases() async throws -> Bool

    /// Check if user is entitled to premium features
    func checkEntitlement() async -> Bool

    /// Get the selected/recommended product
    func getRecommendedProduct() -> IAPProduct?
}

// MARK: - Premium Features

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

extension IAPServiceProtocol {
    var premiumFeatures: [PremiumFeature] {
        [
            PremiumFeature(
                icon: "ic-green-tick-br",
                title: "Ad Free Experience",
                description: "Remove all ads from the app"
            ),
            PremiumFeature(
                icon: "ic-green-tick-br",
                title: "Remove Watermark",
                description: "Export photos without watermark"
            ),
            PremiumFeature(
                icon: "ic-green-tick-br",
                title: "Unlimited Exports",
                description: "Export as many photos as you want"
            ),
            PremiumFeature(
                icon: "ic-green-tick-br",
                title: "Priority Processing",
                description: "Faster object removal processing"
            )
        ]
    }
}
