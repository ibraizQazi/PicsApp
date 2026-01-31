//
//  DummyAdService.swift
//  ObjectRemover
//
//  Dummy implementation of ad service.
//  Shows placeholder ads for development/testing.
//  Replace with actual ad SDK implementation in production.
//

import SwiftUI
import Combine

final class DummyAdService: AdServiceProtocol {

    // MARK: - Properties

    private(set) var shouldShowAds: Bool = true
    private let adEventsSubject = PassthroughSubject<AdEvent, Never>()

    var adEventsPublisher: AnyPublisher<AdEvent, Never> {
        adEventsSubject.eraseToAnyPublisher()
    }

    private var loadedAds: Set<AdPlacement> = []

    // MARK: - Initialization

    init() {}

    // MARK: - AdServiceProtocol

    func initialize() async {
        // Simulate SDK initialization
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    func loadAd(for placement: AdPlacement) async {
        // Simulate ad loading
        try? await Task.sleep(nanoseconds: 200_000_000)
        loadedAds.insert(placement)
        adEventsSubject.send(.loaded(placement))
    }

    func isAdReady(for placement: AdPlacement) -> Bool {
        loadedAds.contains(placement)
    }

    func bannerView(for placement: AdPlacement) -> AnyView {
        AnyView(DummyBannerAdView(placement: placement))
    }

    @MainActor
    func showInterstitial(for placement: AdPlacement) async -> Bool {
        guard shouldShowAds else { return false }

        adEventsSubject.send(.shown(placement))
        // Simulate interstitial display
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        adEventsSubject.send(.dismissed(placement))
        return true
    }

    @MainActor
    func showRewarded(for placement: AdPlacement) async -> Bool {
        guard shouldShowAds else { return false }

        adEventsSubject.send(.shown(placement))
        // Simulate rewarded ad display
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        adEventsSubject.send(.rewardEarned(placement, reward: 1))
        adEventsSubject.send(.dismissed(placement))
        return true
    }

    func setPremiumStatus(_ isPremium: Bool) {
        shouldShowAds = !isPremium
    }
}

// MARK: - Dummy Banner View

struct DummyBannerAdView: View {
    let placement: AdPlacement

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))

            VStack(spacing: 4) {
                Image(systemName: "megaphone.fill")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("Ad Placeholder")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(placement.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 60)
        .padding(.horizontal)
    }
}
