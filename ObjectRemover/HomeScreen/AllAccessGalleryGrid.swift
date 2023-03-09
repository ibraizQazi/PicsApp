//
//  AllAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 22/01/2023.
//

import SwiftUI

struct AllAccessGalleryGrid: View {
    
    @StateObject var viewModel = AllAccessViewModel()
    
    @State private var showPreviewSheet = false
    @State private var showPhotoSheet = false
    @State private var settingsDetent = PresentationDetent.medium

    
    private let columns: [GridItem] = [
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5)
    ]
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                VStack {
                    
                    HStack(spacing: 150) {
                        Text("All Photos")
                            .font(.custom("Gilroy-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding(.leading, 18)
                        
                        Button(action: {
                            print("open gallery")
                            
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
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 4.5) {
                        
                        ForEach(0..<viewModel.items.count, id: \.self) { index in
                            
                            let photo = viewModel.items[index]
                            
                            AsyncImage(url: photo.url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                            .cornerRadius(10)
                            
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
                .background(Color(red: 0.12, green: 0.13, blue: 0.15))
                .cornerRadius(24, corners: [.topLeft, .topRight])
            }
            .clipped()
            .offset(x: 0, y: -40)
            .ignoresSafeArea(edges: .bottom)
            
            NativeAdView()
                .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
                .padding(.bottom, 46)
        }
        .background(Color(red:0.04, green:0.05, blue:0.07))
        .fullScreenCover(isPresented: $showPhotoSheet) {
            PhotoPicker()
        }
        .sheet(isPresented: $showPreviewSheet) {
            
            NavigationView {
                VStack {
                    
                    HStack {
                        
                        Spacer(minLength: 300)
                        
                        Button(action: {
                            showPreviewSheet = false
                        }) {
                            Image("ic-white-cross")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                        }
                        .frame(width: 44, height: 44)
                        
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 5)
                    
                    if viewModel.selectedPhoto != nil {
                        
                        AsyncImage(url: viewModel.selectedPhoto?.url) { image in
                            image
                                .resizable()
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .frame(width: 343, height: 343)
                                .cornerRadius(16)
                                .padding(.bottom, 18)
                            
                        } placeholder: {
                            ProgressView()
                        }
                        
                        
                    } else {
                        Text("error")
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
                .background(Color(red: 30/255, green: 32/255, blue: 39/255))
                .presentationDetents(
                    [.height(UIScreen.main.bounds.height * 0.71)],
                    selection: $settingsDetent
                )
            }
        }
        
    }

}

struct AllAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "grizzly", withExtension: "jpg") {
////            GridItemView(size: 50, item: Item(url: url))
//
            AllAccessGalleryGrid(viewModel: AllAccessViewModel())
//
//        }
    }
}
