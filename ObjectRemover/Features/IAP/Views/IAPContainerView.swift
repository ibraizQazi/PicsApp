//
//  IAPContainerView.swift
//  ObjectRemover
//
//  Container view for the In-App Purchase screen.
//  Integrates with IAPCoordinator for state management.
//

import SwiftUI

struct IAPContainerView: View {
    @EnvironmentObject var coordinator: IAPCoordinator

    // MARK: - Colors

    private let colorN30 = Color(red: 0.93, green: 0.93, blue: 0.93)
    private let selectedBg = Color(red: 1, green: 0.8, blue: 0.05)
    private let colorN800 = Color(red: 0.12, green: 0.13, blue: 0.15)
    private let unSelectedBg = Color(red: 0, green: 0, blue: 0, opacity: 0.7)

    var body: some View {
        ZStack {
            // Background
            Image("bg-iap")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)

            // Content
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.bottom, 50)

                // Title
                titleView
                    .padding(.bottom, 18)

                // Features
                featuresView
                    .padding(.bottom, 40)

                // Products
                if coordinator.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.bottom, 40)
                } else {
                    productsView
                        .padding(.bottom, 40)
                }

                // Legal links
                legalLinksView
                    .padding(.bottom, 22)

                // Continue button
                continueButton
            }

            // Loading overlay
            if coordinator.isPurchasing || coordinator.isRestoring {
                loadingOverlay
            }
        }
        .onAppear {
            coordinator.loadProducts()
        }
        .alert("Error", isPresented: $coordinator.showError) {
            Button("OK") {}
        } message: {
            Text(coordinator.errorMessage)
        }
        .alert("Success!", isPresented: $coordinator.purchaseSuccess) {
            Button("Continue") {
                coordinator.dismiss()
            }
        } message: {
            Text("You now have access to all premium features!")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // Close button
            Button(action: coordinator.dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)
            .background(Color(red: 0.24, green: 0.24, blue: 0.27))
            .clipShape(Circle())
            .padding(.leading, 16)

            Spacer()

            // Restore button
            Button(action: coordinator.restore) {
                Text("RESTORE")
                    .font(.custom("Gilroy-SemiBold", size: 13))
                    .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.68))
            }
            .frame(width: 78, height: 34)
            .background(Color(red: 0.07, green: 0.08, blue: 0.11))
            .cornerRadius(100)
            .padding(.trailing, 16)
            .disabled(coordinator.isRestoring)
        }
    }

    // MARK: - Title

    private var titleView: some View {
        HStack(spacing: 0) {
            Text("SnapErase")
                .font(.custom("Gilroy-Bold", size: 26))
                .foregroundColor(.white)
                .padding(.trailing, 16)

            Text("PRO")
                .font(.custom("Gilroy-Bold", size: 14))
                .frame(width: 52, height: 26)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 179/255, green: 1, blue: 171/255),
                            Color(red: 18/255, green: 1, blue: 247/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.black)
                .cornerRadius(16)
        }
    }

    // MARK: - Features

    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 17) {
            ForEach(coordinator.dependencyContainer.iapService.premiumFeatures) { feature in
                HStack {
                    Image(feature.icon)
                        .resizable()
                        .frame(width: 16, height: 16)

                    Text(feature.title)
                        .font(.custom("Gilroy-SemiBold", size: 17))
                        .foregroundColor(colorN30)
                }
            }
        }
        .frame(width: 339)
        .padding(.vertical, 24)
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
        .cornerRadius(24)
    }

    // MARK: - Products

    private var productsView: some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(coordinator.products) { product in
                ProductCard(
                    product: product,
                    isSelected: coordinator.selectedProduct?.id == product.id,
                    selectedBg: selectedBg,
                    unSelectedBg: unSelectedBg,
                    colorN30: colorN30,
                    colorN800: colorN800,
                    onSelect: { coordinator.selectProduct(product) }
                )
            }
        }
    }

    // MARK: - Legal Links

    private var legalLinksView: some View {
        HStack(spacing: 12) {
            Button(action: coordinator.openTerms) {
                Text("Terms of Service")
                    .font(.custom("Gilroy-Medium", size: 14))
                    .foregroundColor(colorN30)
                    .underline()
            }

            Image("ic-seperator")
                .resizable()
                .scaledToFit()
                .frame(width: 4, height: 4)

            Button(action: coordinator.openPrivacy) {
                Text("Privacy Policy")
                    .font(.custom("Gilroy-Medium", size: 14))
                    .foregroundColor(colorN30)
                    .underline()
            }
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button(action: coordinator.purchase) {
            VStack(spacing: 4) {
                Text(continueButtonText)
                    .font(.custom("Gilroy-Bold", size: 20))
                    .foregroundColor(.black)

                if let product = coordinator.selectedProduct, product.type.hasFreeTrial {
                    Text("\(product.type.trialDays)-Day Free Trial")
                        .font(.custom("Gilroy-Medium", size: 14))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(.top, 18)
            .background(selectedBg)
            .clipShape(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
            )
        }
        .disabled(coordinator.selectedProduct == nil || coordinator.isPurchasing)
    }

    private var continueButtonText: String {
        if let product = coordinator.selectedProduct {
            if product.type.hasFreeTrial {
                return "Start Free Trial"
            } else if product.type == .lifetime {
                return "Get Lifetime Access"
            }
        }
        return "Continue"
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text(coordinator.isRestoring ? "Restoring..." : "Processing...")
                    .font(.custom("Gilroy-Medium", size: 16))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
}

// MARK: - Product Card

private struct ProductCard: View {
    let product: IAPProduct
    let isSelected: Bool
    let selectedBg: Color
    let unSelectedBg: Color
    let colorN30: Color
    let colorN800: Color
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Header
                Text(product.type.displayName)
                    .frame(width: 155, height: 30)
                    .font(.custom("Gilroy-Bold", size: 17))
                    .foregroundColor(isSelected ? .white : colorN30)
                    .background(isSelected ? colorN800 : unSelectedBg)
                    .overlay(
                        Rectangle()
                            .fill(isSelected ? colorN800 : colorN30)
                            .frame(height: 1),
                        alignment: .bottom
                    )

                // Price section
                VStack(spacing: 4) {
                    Text(product.priceString)
                        .font(.custom("Gilroy-Bold", size: 34))
                        .foregroundColor(isSelected ? .black : colorN30)

                    if let savings = product.savingsPercent {
                        Text("SAVE \(savings)%")
                            .font(.custom("Gilroy-SemiBold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text("/\(product.type.period)")
                            .font(.custom("Gilroy-SemiBold", size: 14))
                            .foregroundColor(isSelected ? .black.opacity(0.7) : colorN30)
                    }
                }
                .frame(width: 155, height: 100)
                .background(isSelected ? selectedBg : unSelectedBg)
            }
            .overlay(
                Group {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: 55, y: -55)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? selectedBg : colorN30, lineWidth: isSelected ? 4 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let coordinator = IAPCoordinator(
        dependencyContainer: container,
        onDismiss: {},
        onPurchaseComplete: {}
    )
    return IAPContainerView()
        .environmentObject(coordinator)
}
