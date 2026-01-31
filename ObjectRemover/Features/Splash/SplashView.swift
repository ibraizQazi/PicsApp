//
//  SplashView.swift
//  ObjectRemover
//
//  Splash screen shown on app launch.
//  Displays loading animation while services initialize.
//

import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack {
            Spacer(minLength: 250)

            // Logo and title
            VStack(spacing: 16) {
                Image("splash-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                Text("SnapErase")
                    .font(.custom("Gilroy-Bold", size: 24))
                    .foregroundColor(.black)
                    .tracking(-0.5)
            }
            .frame(maxWidth: 180, maxHeight: 120)

            Spacer(minLength: 260)

            // Loading indicator
            VStack(spacing: 8) {
                LottieLoaderView(lottieFile: "qr-code-loader")
                    .frame(width: 78, height: 78)

                Text("AI model is warming up...")
                    .font(.custom("Gilroy-SemiBold", size: 14))
                    .foregroundColor(.black)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: 160, maxHeight: 160)
            .padding(.bottom, 70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            startInitialization()
        }
    }

    private func startInitialization() {
        // Simulate model loading / service initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                onComplete()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onComplete: {})
}
