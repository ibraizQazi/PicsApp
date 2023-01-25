//
//  AllAccessGalleryGrid.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 22/01/2023.
//

import SwiftUI

struct AllAccessGalleryGrid: View {
    @Binding var photoList: [PhotoItem]
    
    private let columns: [GridItem] = [
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5),
        GridItem(.fixed(110), spacing: 4.5)
    ]

    var openGallery: ()->Void
    var showPreviewSheet: (Image)->Void
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 150) {
                Text("All Photos")
                    .font(.custom("Gilroy-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.leading, 18)
                
                Button(action: {
                    print("open gallery")
                    openGallery()
                }) {
                    Text("Open Gallery")
                        .font(.custom("Gilroy-Bold", size: 14))
                        .foregroundColor(.black)
                        .frame(width: 107, height: 38)
                        .background(.white)
                        .cornerRadius(100)
                    
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 13)
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 4.5) {
                
                ForEach(0..<photoList.count, id: \.self) { index in
                    
                    let photo = photoList[index]
                    
                    photo.image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                        .cornerRadius(10)
                        .onTapGesture {
                            print("open preview")
                            showPreviewSheet(photo.image)
                        }
                    
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

struct AllAccessGalleryGrid_Previews: PreviewProvider {
    static var previews: some View {
        AllAccessGalleryGrid(
            photoList: .constant(PhotoItem.sampleData),
            openGallery: {},
            showPreviewSheet: {_ in Image("placeholder-image")}
        )
    }
}
