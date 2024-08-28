//
//  PartialAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 23/01/2023.
//

import SwiftUI

struct PartialAccessGalleryGrid: View {
    
    @ObservedObject var photoCollection : PhotoCollection

    @Environment(\.displayScale) private var displayScale
    @Binding var previewAsset: PhotoAsset?
    @State private var showPhotoSheet = false
    @State private var settingsDetent = PresentationDetent.medium

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
            if !photoCollection.photoAssets.isEmpty {
                
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: Self.itemSpacing) {
                        
                        AddImageView()
                            .onTapGesture {
                                print("open photo sheet")
                                self.showPhotoSheet = true
                            }
                            .contentShape(Rectangle())
                        
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
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
                    
                }
                .clipped()
                .offset(x: 0, y: 100)
                .ignoresSafeArea(edges: .bottom)
                
                
            } else {
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(0...5, id: \.self) { index in
                        if index == 0 {
                            AddImageView()
                                .onTapGesture {
                                    print("open photo sheet")
                                    self.showPhotoSheet = true
                                }
                                .contentShape(Rectangle())
                            
                        } else {
                            Color(red: 18/255, green: 20/255, blue: 28/255)
                                .scaledToFill()
                                .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                                .cornerRadius(10.0)
                        }
                        
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
                .offset(x: 0, y: 40)
                .ignoresSafeArea(edges: .bottom)
            }
            
            NativeAdView()
                .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
                .padding(.bottom, 46)
            
        }
        .task {
            await photoCollection.loadPhotos()
        }
        .fullScreenCover(isPresented: $showPhotoSheet) {
            PhotoPicker(photoCollection: photoCollection)
        }
//        .sheet(item: $previewAsset, content: { asset in
//            NavigationView {
//                VStack {
//                    
//                    HStack {
//                        
//                        Spacer(minLength: 300)
//                        
//                        Button(action: {
//                            print("close preview sheet")
//                            previewAsset = nil
//                        }) {
//                            Image("ic-white-cross")
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 18, height: 18)
//                                .contentShape(Rectangle())
//                        }
//                        .frame(width: 44, height: 44)
//                        
//                    }
//                    .padding(.trailing, 8)
//                    .padding(.top, 8)
//                    .padding(.bottom, 5)
//
//                    PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: Self.previewImageSize)
//                        .frame(width: Self.previewImageSize.width, height: Self.previewImageSize.height)
//                        .clipped()
//                        .onAppear {
//                            Task {
//                                await photoCollection.cache.startCaching(for: [asset], targetSize: Self.previewImageSize)
//                            }
//                        }
//                        .onDisappear {
//                            Task {
//                                await photoCollection.cache.stopCaching(for: [asset], targetSize: Self.previewImageSize)
//                            }
//                        }
//                    
//                    
//                    NavigationLink(destination: EditorScreenView(), label: {
//                        Text("Process Image")
//                            .font(.custom("Gilroy-SemiBold", size: 17))
//                            .frame(width: 343, height: 45)
//                            .background(
//                                LinearGradient(
//                                    colors: [Color(red: 179/255, green: 1, blue: 171/255), Color(red: 18/255, green: 1, blue: 247/255)],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ))
//                            .foregroundColor(.black)
//                            .cornerRadius(16)
//                    })
//                    .navigationBarBackButtonHidden()
////                    .navigationBarHidden(true)
//                    
//                    Spacer(minLength: 28)
//                    
//                    NativeAdView()
//                        .frame(minWidth: UIScreen.main.bounds.width, minHeight: 60)
//                }
//                
//            }
//            .background(Color(red: 30/255, green: 32/255, blue: 39/255))
//            .presentationDetents(
//                [.height(UIScreen.main.bounds.height * 0.71)],
//                selection: $settingsDetent
//            )
//        })
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

struct PartialAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "grizzly", withExtension: "jpg") {
        PartialAccessGalleryGrid(photoCollection: PhotoCollection(smartAlbum: .smartAlbumUserLibrary), previewAsset: .constant(nil))
//        }
    }
}

