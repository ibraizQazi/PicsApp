//
//  PartialAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 23/01/2023.
//

import SwiftUI

struct PartialAccessGalleryGrid: View {
    @Binding var photoList: [PhotoItem]
    
    private let columns: [GridItem] = [
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5)
    ]
    
    var showPhotoSheet: ()->Void
    var showPreviewSheet: (Image)->Void
    
    var body: some View {
        
        if photoList.count > 1 {
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 4.5) {
                
                ForEach(0..<photoList.count, id: \.self) { index in
                    
                    let photo = photoList[index]
                    
                    if index == 0 {
                        VStack(spacing: 18) {
                            
                            Image("ic-import")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 21.5, height: 21.5)
                            
                            
                            Text("IMPORT PHOTO")
                                .font(.custom("Gilroy-Bold", size: 12))
                                .foregroundColor(.white)
                                .tracking(-0.2)
                        }
                        .frame(minWidth: 108, maxWidth: 108,minHeight: 108 ,maxHeight: 108)
                        .background(Color(red: 0.07, green: 0.08, blue: 0.11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 2)
                        )
                        .cornerRadius(10.0)
                        .onTapGesture {
                            if index == 0 {
                                print("open photo sheet")
                                showPhotoSheet()
                            } else {
                                showPreviewSheet(photo.image)
                            }
                        }
                        
                    } else  {
                        
                        photo.image
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                            .cornerRadius(10)
                            .onTapGesture {
                                if index == 0 {
                                    print("open photo sheet")
                                    showPhotoSheet()
                                } else {
                                    print("open preview")
                                    showPreviewSheet(photo.image)
                                }
                            }
                        
                    }
                    
                }
            }
        
        } else {
            
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(0...5, id: \.self) { index in
                    if index == 0 {
                        VStack(spacing: 18) {
                            
                            Image("ic-import")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 21.5, height: 21.5)
                            
                            
                            Text("IMPORT PHOTO")
                                .font(.custom("Gilroy-Bold", size: 12))
                                .foregroundColor(.white)
                                .tracking(-0.2)
                        }
                        .frame(minWidth: 108, maxWidth: 108,minHeight: 108 ,maxHeight: 108)
                        .background(Color(red: 0.07, green: 0.08, blue: 0.11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 2)
                        )
                        .cornerRadius(10.0)
                        .onTapGesture {
                            print("open photo sheet")
                            showPhotoSheet()
                        }
                        
                    } else {
                        Color(red: 18/255, green: 20/255, blue: 28/255)
                            .scaledToFill()
                            .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                            .cornerRadius(10.0)
                    }
                    
                }
            }
            
        }
        
    }
}

struct PartialAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
        PartialAccessGalleryGrid(photoList: .constant(PhotoItem.sampleData), showPhotoSheet: {}, showPreviewSheet: {_ in Image("placeholder-image")})
    }
}

