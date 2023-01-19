//
//  HomeView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 26/12/2022.
//

import SwiftUI
import PhotosUI
import Photos

struct HomeView: View {
   
    @State private var photos: [PhotoItem] = [PhotoItem(image: Image("ic-import"))]
    @State private var selectedPhoto: Image? = nil
    @State private var showPhotoSheet = false
    @State private var showPreviewSheet = false
    @State private var image: UIImage? = nil
    @State private var isPermissionGiven = true
    
    @State private var settingsDetent = PresentationDetent.medium

    private let columns: [GridItem] = [GridItem(.fixed(110)), GridItem(.fixed(110)), GridItem(.fixed(110))]
    
    var body: some View {
        
        VStack {
            
            if isPermissionGiven {
                
                if photos.count > 1 {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            ScrollView {
                                LazyVGrid(columns: columns) {
                                    ForEach(0..<photos.count, id: \.self) { index in
                                        
                                        let photo = photos[index]
                                        
                                        if index == 0 {
                                            VStack {
                                                
                                                Image("ic-import")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(minWidth: 22, maxWidth: 22,minHeight: 22 ,maxHeight: 22)
                                                    .padding(.bottom, 17)
                                                
                                                
                                                Text("IMPORT PHOTO")
                                                    .font(.custom("Gilroy_Regular", size: 12))
                                                    .foregroundColor(.white)
                                            }
                                            .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                                            .background(Color(red: 18/255, green: 20/255, blue: 28/255))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.white, lineWidth: 2)
                                            )
                                            .cornerRadius(10.0)
                                            .padding()
                                            .onTapGesture {
                                                if index == 0 {
                                                    print("open photo sheet")
                                                    showPhotoSheet.toggle()
                                                } else {
                                                    showPreviewSheet.toggle()
                                                    selectedPhoto = photo.image
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
                                                        showPhotoSheet.toggle()
                                                    } else {
                                                        print("open preview")
                                                        showPreviewSheet.toggle()
                                                        selectedPhoto = photo.image
                                                    }
                                                }
                                            
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal, 12)
                                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                                .background(.red)
                                
                                
//                        .frame(width: geo.size.width, height: geo.size.height)
//                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .center)
                            }
                        
                            NativeAdView()
                                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 114, maxHeight: 114)
                                .background(
                                    Rectangle()
                                        .fill(.black.opacity(0.2))
                                        .blur(radius: 4)
                                        .ignoresSafeArea(.all)
                                )
                                .padding(.top, 30)
                                .padding(.bottom, 0)
                            
                        }
                    }
                    .background(Color(red:11/255,green:12/255,blue:17/255))
                    
                    
                } else {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            LazyVGrid(columns: columns, alignment: .center) {
                                ForEach(0...5, id: \.self) { index in
                                    if index == 0 {
                                        VStack {
                                            
                                            Image("ic-import")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: 22, maxWidth: 22,minHeight: 22 ,maxHeight: 22)
                                                .padding(.bottom, 17)
                                            
                                            
                                            Text("IMPORT PHOTO")
                                                .font(.custom("Gilroy_Regular", size: 12))
                                                .foregroundColor(.white)
                                        }
                                        .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                                        .background(Color(red: 18/255, green: 20/255, blue: 28/255))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                        .cornerRadius(10.0)
                                        .padding()
                                        .onTapGesture {
                                            print("open photo sheet")
                                            showPhotoSheet.toggle()
                                        }
                                        
                                    } else {
                                        Color(red: 18/255, green: 20/255, blue: 28/255)
                                            .scaledToFill()
                                            .frame(minWidth: 110, maxWidth: 110,minHeight: 110 ,maxHeight: 110)
                                            .cornerRadius(10.0)
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                            .background(.red)
                            
                            NativeAdView()
                                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 114, maxHeight: 114)
                                .background(
                                    Rectangle()
                                        .fill(.black.opacity(0.2))
                                        .blur(radius: 4)
                                        .ignoresSafeArea(.all)
                                )
                                .padding(.top, 30)
                                .padding(.bottom, 0)
                        }
//                        .frame(width: geo.size.width, height: .infinity)
//                        .frame(minWidth: geo.size.width, maxWidth: .infinity, minHeight: geo.size.height, maxHeight: .infinity)
                    }
                    .background(Color(red:11/255,green:12/255,blue:17/255))
                    
                }
                
            } else {

                GeometryReader { geo in
                    VStack {
                        
                        PhotoAccessView(openPermissions: {
                            isPermissionGiven = true
                        })
                        .frame(width: 343, height: 587)
                        .padding(.horizontal, 16)
                        .background(Color(red:11/255,green:12/255,blue:17/255))
                        
                        NativeAdView()
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 114, maxHeight: 114)
                            .background(
                                Rectangle()
                                    .fill(.red)
                                    .blur(radius: 20)
                                    .ignoresSafeArea(.all)
                            )
                            .padding(.top, 0)
                            .padding(.bottom, 100)
                    }
                    .frame(width:geo.size.width, height: geo.size.height)
                    .background(Color(red:11/255,green:12/255,blue:17/255))

                }
            }
            
        }
        .toolbar {
            
            HStack(alignment: .center) {
                
                Text("OBJECT REMOVER")
                    .font(.custom("Gilroy-Bold", size: 22))
                    .foregroundColor(.white)
                    .frame(width: 187, height: 26)
                    .padding(.leading, 18)
                
                Spacer(minLength: 8)
                
                Button(action: {
                    print("PRO CTA")
                }) {
                    Text("PRO")
                        .font(.custom("Gilroy-Bold", size: 14))
                        .frame(width: 52, height: 26)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 179/255, green: 1, blue: 171/255),
                                         Color(red: 18/255, green: 1, blue: 247/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
                .frame(maxWidth: .infinity, maxHeight: 48, alignment: .trailing)
                .padding(.trailing, 18)
                

            }
            .frame(width: UIScreen.main.bounds.width, height: 64, alignment: .center)
            .background(.black)
            
        }
        
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(isPresented: $showPhotoSheet) {
            PhotoPicker(filter: .images, limit: 1) { results in
                PhotoPicker.convertToUIImageArray(fromResults: results) { (imagesOrNil, errorOrNil) in
                    if let error = errorOrNil {
                        print(error)
                    }
                    if let images = imagesOrNil {
                        if let first = images.first {
                            print(first)
                            image = first
                            photos.append(PhotoItem(image: Image(uiImage: first)))
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showPreviewSheet) {

            VStack {

                HStack{
                    Spacer(minLength: 300)
                    
                    Button(action: {
                        showPreviewSheet.toggle()
                    }) {
                        Image("ic-white-cross")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 18, height: 18)
                    }
                    
                }.padding()

                Image("placeholder-image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 327, height: 327)
                    .cornerRadius(16)
                
                Spacer(minLength: 24)

                Button(action: {
                    showPreviewSheet.toggle()
                }) {
                    Text("Process Image")
                        .font(.custom("Gilroy-Regular", size: 17))
                        .frame(width: 327, height: 45)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 179/255, green: 1, blue: 171/255), Color(red: 18/255, green: 1, blue: 247/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }

                Spacer(minLength: 28)

                NativeAdView()
                    .frame(minWidth: UIScreen.main.bounds.width, minHeight: 60)
            }
            .background(Color(red: 30/255, green: 32/255, blue: 39/255))
            .presentationDetents(
                [.height(UIScreen.main.bounds.height * 0.70)],
                selection: $settingsDetent
            )
        }

    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
