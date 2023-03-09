//
//  PartialAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 23/01/2023.
//

import SwiftUI

struct PartialAccessGalleryGrid: View {
    
    @StateObject var viewModel = PartialAccessViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5)
    ]
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.items.count > 1 {
                
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 4.5) {
                        
                        ForEach(0..<viewModel.items.count, id: \.self) { index in
                            
                            let photo = viewModel.items[index]
                            
                            if index == 0 {
                                AddImageView()
                                    .onTapGesture {
                                        if index == 0 {
                                            print("open photo sheet")
                                        }
                                    }
                                    .contentShape(Rectangle())
                                
                            } else  {
                                
                                AsyncImage(url: photo.url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                    
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                                .cornerRadius(10)
                                .onTapGesture {
                                    print("open preview")
                                    viewModel.setSelectedPhoto(imageItem: photo)
                                }
                                .contentShape(Rectangle())
                                .task {
                                    if viewModel.hasReachedEnd(imageItem: photo) {
                                        print("reached end")
                                    }
                                }
                            }
                            
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
                    
                }
                .clipped()
                .offset(x: 0, y: -40)
                .ignoresSafeArea(edges: .bottom)
                
                
            } else {
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(0...5, id: \.self) { index in
                        if index == 0 {
                            AddImageView()
                                .onTapGesture {
                                    print("open photo sheet")
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
                .offset(x: 0, y: -40)
                .ignoresSafeArea(edges: .bottom)
            }
            
            NativeAdView()
                .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
                .padding(.bottom, 46)
            
        }
    }
}

struct PartialAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "grizzly", withExtension: "jpg") {
            PartialAccessGalleryGrid()
//        }
    }
}

