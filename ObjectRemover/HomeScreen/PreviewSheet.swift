//
//  PreviewSheet.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 27/04/2023.
//

import SwiftUI

struct PreviewSheet: View {
    
    @Binding var previewAsset: PhotoAsset?
    @EnvironmentObject var photoCollection: PhotoCollection
    
    @Environment(\.displayScale) private var displayScale
    
    private static let itemSpacing = 4.5
    private static let itemCornerRadius = 10.0
    private static let itemSize = CGSize(width: 110, height: 110)
    private static let previewImageSize = CGSize(width: 343, height: 343)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    var body: some View {
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
            
            PhotoItemView(asset: previewAsset!, cache: photoCollection.cache, imageSize: Self.previewImageSize)
                .frame(width: Self.previewImageSize.width, height: Self.previewImageSize.height)
                .clipped()
                .onAppear {
                    Task {
                        await photoCollection.cache.startCaching(for: [previewAsset!], targetSize: Self.previewImageSize)
                    }
                }
                .onDisappear {
                    Task {
                        await photoCollection.cache.stopCaching(for: [previewAsset!], targetSize: Self.previewImageSize)
                    }
                }
            
            Button(action: {
                if previewAsset != nil {
//                    photoAsset = previewAsset
                    previewAsset = nil
                }
            } , label: {
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
}

//struct PreviewSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewSheet(previewAsset: .constant(nil), photoCollection: .constant(PhotoCollection(smartAlbum: .smartAlbumUserLibrary)))
//    }
//}
