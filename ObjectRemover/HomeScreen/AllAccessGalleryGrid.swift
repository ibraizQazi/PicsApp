//
//  AllAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 22/01/2023.
//

import SwiftUI
import Photos

struct AllAccessGalleryGrid: View {
    
    @ObservedObject var photoCollection : PhotoCollection
    
    @State private var showPreviewSheet = false
    @State var previewAsset: PhotoAsset?
    @State private var showPhotoSheet = false
    @State private var settingsDetent = PresentationDetent.medium

    @Environment(\.displayScale) private var displayScale

    private static let itemSpacing = 4.5
    private static let itemCornerRadius = 10.0
    private static let itemSize = CGSize(width: 110, height: 110)
    private static let previewImageSize = CGSize(width: 343, height: 343)

    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns: [GridItem] = [
        GridItem(.fixed(itemSize.width), spacing: itemSpacing),
        GridItem(.fixed(itemSize.width), spacing: itemSpacing),
        GridItem(.fixed(itemSize.width), spacing: itemSpacing)
    ]    
    
    var body: some View {
        ZStack(alignment: .bottom) {

           ScrollView {
                
                HStack(spacing: 150) {
                    Text("All Photos")
                        .font(.custom("Gilroy-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding(.leading, 18)
                    
                    Button(action: {
                        print("open gallery")
                        self.showPhotoSheet = true
                    }) {
                        Text("Open Gallery")
                            .font(.custom("Gilroy-Bold", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 107, height: 38)
                            .background(.white)
                            .cornerRadius(100)
                    }
                    .padding(.trailing, 16)
                    
                }
                .padding(.horizontal, 0)
                .padding(.top, 18)
                .padding(.bottom, 13)
                
                LazyVGrid(columns: columns, alignment: .center, spacing: Self.itemSpacing) {
                    ForEach(photoCollection.photoAssets) { asset in
                        photoItemView(asset: asset)
                            .accessibilityLabel(asset.accessibilityLabel)
                            .onTapGesture {
                                print("open photo asset")
                                self.previewAsset = asset
                            }
                            .contentShape(Rectangle())
                    }
                    
                }
            }
            .clipped()
            .background(Color(red: 0.12, green: 0.13, blue: 0.15))
//            .offset(x: 0, y: -40)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .ignoresSafeArea(edges: .bottom)
            
            NativeAdView()
                .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
                .padding(.bottom, 46)
        }
        .task {
            await photoCollection.loadPhotos()
        }
        .background(Color(red:0.04, green:0.05, blue:0.07))
        .fullScreenCover(isPresented: $showPhotoSheet) {
            PhotoPicker(photoCollection: photoCollection)
        }
        .sheet(item: $previewAsset, content: { asset in
            NavigationView {
                VStack {
                    
                    HStack {
                        
                        Spacer(minLength: 300)
                        
                        Button(action: {
                            print("close preview sheet")
                            previewAsset = nil
                        }) {
                            Image("ic-white-cross")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                                .contentShape(Rectangle())
                        }
                        .frame(width: 44, height: 44)
                        
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 5)
                    
                    PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: Self.previewImageSize)
                        .frame(width: Self.previewImageSize.width, height: Self.previewImageSize.height)
                        .clipped()
                        .onAppear {
                            Task {
                                await photoCollection.cache.startCaching(for: [asset], targetSize: Self.previewImageSize)
                            }
                        }
                        .onDisappear {
                            Task {
                                await photoCollection.cache.stopCaching(for: [asset], targetSize: Self.previewImageSize)
                            }
                        }
                    
                    
                    NavigationLink(destination: EditorScreenView(), label: {
                        Text("Process Image")
                            .font(.custom("Gilroy-SemiBold", size: 17))
                            .frame(width: 343, height: 45)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 179/255, green: 1, blue: 171/255), Color(red: 18/255, green: 1, blue: 247/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    })
                    
                    Spacer(minLength: 28)
                    
                    NativeAdView()
                        .frame(minWidth: UIScreen.main.bounds.width, minHeight: 60)
                }
                
            }
            .background(Color(red: 30/255, green: 32/255, blue: 39/255))
            .presentationDetents(
                [.height(UIScreen.main.bounds.height * 0.71)],
                selection: $settingsDetent
            )
        })
        
    }
    
    private func photoItemView(asset: PhotoAsset) -> some View {
        PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: imageSize)
            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            .clipped()
            .cornerRadius(Self.itemCornerRadius)
            .onAppear {
                Task {
                    await photoCollection.cache.startCaching(for: [asset], targetSize: imageSize)
                }
            }
            .onDisappear {
                Task {
                    await photoCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
                }
            }
    }

}

struct AllAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "grizzly", withExtension: "jpg") {
//            GridItemView(size: 50, item: Item(url: url))
//
        AllAccessGalleryGrid(photoCollection: PhotoCollection(smartAlbum: .smartAlbumUserLibrary))
//
//        }
    }
}
