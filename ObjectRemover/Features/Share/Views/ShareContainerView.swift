//
//  ShareContainerView.swift
//  ObjectRemover
//
//  Container view for sharing/saving processed images.
//

import SwiftUI

struct ShareContainerView: View {
    @EnvironmentObject var coordinator: ShareCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Image preview
                    imagePreview

                    // Success message
                    if coordinator.saveSuccess {
                        successMessage
                    }

                    Spacer()

                    // Action buttons
                    actionButtons

                    // Ad placeholder
                    AdShareBannerPlaceholder()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SHARE")
                        .font(.custom("Gilroy-Bold", size: 14))
                        .tracking(0.3)
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: coordinator.dismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .overlay {
                if coordinator.isSaving {
                    savingOverlay
                }
            }
            .alert("Error", isPresented: .constant(coordinator.errorMessage != nil)) {
                Button("OK") { coordinator.dismissError() }
            } message: {
                Text(coordinator.errorMessage ?? "")
            }
            .sheet(isPresented: $coordinator.showingShareSheet) {
                ShareSheet(items: [coordinator.image])
            }
        }
    }

    // MARK: - Image Preview

    private var imagePreview: some View {
        Image(uiImage: coordinator.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .frame(maxHeight: 400)
    }

    // MARK: - Success Message

    private var successMessage: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)

            Text("Photo saved to library")
                .font(.custom("Gilroy-Medium", size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Save to Photos
            Button(action: {
                Task {
                    await coordinator.saveToPhotos()
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save to Photos")
                }
                .font(.custom("Gilroy-Bold", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(25)
            }
            .disabled(coordinator.saveSuccess || coordinator.isSaving)
            .opacity(coordinator.saveSuccess ? 0.5 : 1)

            // Share
            Button(action: coordinator.showShareSheet) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(.custom("Gilroy-Bold", size: 16))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(25)
            }

            // Done
            Button(action: coordinator.dismiss) {
                Text("Done")
                    .font(.custom("Gilroy-Bold", size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Saving Overlay

    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("Saving...")
                    .font(.custom("Gilroy-Medium", size: 14))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Ad Banner Placeholder

private struct AdShareBannerPlaceholder: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))

            HStack {
                Image(systemName: "megaphone.fill")
                    .foregroundColor(.gray)
                Text("Ad Placeholder")
                    .font(.custom("Gilroy-Medium", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 60)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let coordinator = ShareCoordinator(
        image: UIImage(systemName: "photo")!,
        dependencyContainer: container,
        onDismiss: {}
    )
    return ShareContainerView()
        .environmentObject(coordinator)
}
