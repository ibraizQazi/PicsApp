//
//  AdServiceProtocol.swift
//  ObjectRemover
//
//  Protocol abstraction for ad service.
//  Can be implemented with Google AdMob, Unity Ads, or dummy implementation.
//

import SwiftUI
import Combine

// MARK: - Ad Placement

enum AdPlacement: String, CaseIterable {
    case homeBanner = "home_banner"
    case editorBanner = "editor_banner"
    case shareScreen = "share_screen"
    case interstitialAfterSave = "interstitial_after_save"
    case rewardedForPremiumFeature = "rewarded_premium"

    var adUnitId: String {
        // These would be replaced with real ad unit IDs in production
        switch self {
        case .homeBanner: return "ca-app-pub-test/home"
        case .editorBanner: return "ca-app-pub-test/editor"
        case .shareScreen: return "ca-app-pub-test/share"
        case .interstitialAfterSave: return "ca-app-pub-test/interstitial"
        case .rewardedForPremiumFeature: return "ca-app-pub-test/rewarded"
        }
    }
}

// MARK: - Ad Events

enum AdEvent {
    case loaded(AdPlacement)
    case failedToLoad(AdPlacement, Error)
    case shown(AdPlacement)
    case clicked(AdPlacement)
    case dismissed(AdPlacement)
    case rewardEarned(AdPlacement, reward: Int)
}

// MARK: - Protocol

protocol AdServiceProtocol: AnyObject {
    /// Whether ads should be shown (false if user has premium)
    var shouldShowAds: Bool { get }

    /// Publisher for ad events
    var adEventsPublisher: AnyPublisher<AdEvent, Never> { get }

    /// Initialize the ad SDK
    func initialize() async

    /// Preload an ad for a specific placement
    func loadAd(for placement: AdPlacement) async

    /// Check if an ad is ready for a specific placement
    func isAdReady(for placement: AdPlacement) -> Bool

    /// Get a banner view for a specific placement
    func bannerView(for placement: AdPlacement) -> AnyView

    /// Show an interstitial ad
    /// - Returns: true if the ad was shown successfully
    @MainActor
    func showInterstitial(for placement: AdPlacement) async -> Bool

    /// Show a rewarded ad
    /// - Returns: true if the user earned the reward
    @MainActor
    func showRewarded(for placement: AdPlacement) async -> Bool

    /// Set premium status (to disable ads)
    func setPremiumStatus(_ isPremium: Bool)
}

// MARK: - Banner View Wrapper

struct AdBannerContainerView: View {
    let placement: AdPlacement
    let adService: AdServiceProtocol

    var body: some View {
        if adService.shouldShowAds {
            adService.bannerView(for: placement)
        }
    }
}
