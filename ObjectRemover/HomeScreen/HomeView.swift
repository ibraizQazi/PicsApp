//
//  HomeView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 26/12/2022.
//

import SwiftUI
import PhotosUI
import Photos

struct Photo: Hashable, Identifiable {
    var id = UUID()
    var image: UIImage
}

struct HomeView: View {
    @State private var photos: [Photo] = [Photo(image: UIImage(named: "import-photo")!)]
    
    @State private var showPhotoSheet = false
    @State private var image: UIImage? = nil
    @State private var isPermissionGiven = true
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)
    
    var body: some View {
        
        VStack {
            if isPermissionGiven {
                
                if !photos.isEmpty {
                    
                    ScrollView {
                        LazyVGrid(columns: [ GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()) ]) {
                            ForEach(Array(photos.enumerated()), id: \.element) { index, photo in
                            
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        if index == 0 {
                                            print("open photo sheet")
                                            showPhotoSheet = true
                                        } else {
                                            print("navigate to photoview")
                                        }
                                    }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                    }
                    
                    
                } else {
                    
                    LazyVGrid(columns: [ GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()) ]) {
                        ForEach(0...5, id: \.self) { index in
                            if index == 0 {
                                
                                Image("import-photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        print("open photo sheet")
                                        showPhotoSheet = true
                                    }
                                
                            } else {
                                Color(.gray)
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(10.0)
                            }
                            
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                }
                
            } else {
                PhotoAccessView(openPermissions: {
                    
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("OBJECT REMOVER")
                    .font(.custom("Gilroy_Bold", size: 22))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Text("PRO")
                        .font(.custom("Gilroy-Regular", size: 17))
                        .frame(width: 52, height: 26)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
            }
        }
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
                            photos.append(Photo(image: first))
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .background(Color.gray)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
