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
   
//    @EnvironmentObject var photosModel: PhotosModel
    
    @State private var photos: [PhotoItem] = [PhotoItem(image: Image("ic-import"))]
    
    
    @State private var showPhotoSheet = false
    @State private var showPreviewSheet = false
    @State private var image: UIImage? = nil
    @State private var isPermissionGiven = false
    @State private var isFullAccessGiven = false
    @State private var isDenied = false
    
    @State private var settingsDetent = PresentationDetent.medium

    private let columns: [GridItem] = [GridItem(.fixed(110), spacing: 4.5), GridItem(.fixed(110), spacing: 4.5), GridItem(.fixed(110), spacing: 4.5)]
    
    var body: some View {
        
        VStack {
            
            if isPermissionGiven {
                
                if isFullAccessGiven {
                    
//                    ZStack(alignment: .bottom) {
//                        ScrollView {
                    AllAccessGalleryGrid(viewModel: AllAccessViewModel())
//                        }
//                        .clipped()
//                        .offset(x: 0, y: -40)
//                        .ignoresSafeArea(edges: .bottom)
//
//                        NativeAdView()
//                            .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
//                            .padding(.bottom, 46)
//
//                    }
//                    .background(Color(red:0.04, green:0.05, blue:0.07))
                    
                } else {
                    
//                    ZStack(alignment: .bottom) {
//                        ScrollView {
                            PartialAccessGalleryGrid(viewModel: PartialAccessViewModel())
//                                showPhotoSheet: {showPhotoSheet = true}
//                                showPreviewSheet: { photo in
//                                    selectedPhoto = photo
//                                    showPreviewSheet = true
//                                }
//                            )
//                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
//
//                        }
//                        .clipped()
//                        .offset(x: 0, y: -40)
//                        .ignoresSafeArea(edges: .bottom)
//
//                        NativeAdView()
//                            .frame(width: UIScreen.main.bounds.width, height: 114, alignment: .bottom)
//                            .padding(.bottom, 46)
//                    }
//                    .background(Color(red:0.04, green:0.05, blue:0.07))
//
                }
                
            } else {

                VStack {
                    
                    PhotoAccessView(openPermissions: {
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                            switch status {
                                case .notDetermined:
                                    // The user hasn't determined this app's access.
                                    isPermissionGiven = false
                                    isFullAccessGiven = false
                                case .restricted:
                                    // The system restricted this app's access.
                                    isPermissionGiven = true
                                    isFullAccessGiven = false
                                case .denied:
                                    // The user explicitly denied this app's access.
                                    isPermissionGiven = false
                                    isFullAccessGiven = false
                                    isDenied = true
                                case .authorized:
                                    // The user authorized this app to access Photos data.
                                    isPermissionGiven = true
                                    isFullAccessGiven = true
                                case .limited:
                                    // The user authorized this app for limited Photos access.
                                    isPermissionGiven = true
                                    isFullAccessGiven = false
                            @unknown default:
                                fatalError()
                            }
                        }
                    })
                    .frame(width: 343, height: 587)
                    .padding(.horizontal, 16)
                    .background(Color(red:11/255,green:12/255,blue:17/255))
                    
                    NativeAdView()
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 114, maxHeight: 114)
                        .padding(.top, 0)
                        .padding(.bottom, 100)
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            }
            
        }
        .onAppear {
            
            let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            switch readWriteStatus {
                case .notDetermined:
                    print("not determined")
                    isPermissionGiven = false
                case .restricted:
                    print("restricted")
                    isPermissionGiven = false
                case .denied:
                    print("denied")
                    isPermissionGiven = false
                case .authorized:
                    print("authorized")
                    isFullAccessGiven = true
                    isPermissionGiven = true
                case .limited:
                    print("limited")
                    isPermissionGiven = true
                @unknown default:
                    print("fatalError")
            }
        }
        .background(Color(red: 0.04, green: 0.05, blue: 0.07))
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
            .ignoresSafeArea(edges: .top)
            .frame(width: UIScreen.main.bounds.width, height: 64, alignment: .center)
            .background(.black)
            
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
//        .fullScreenCover(isPresented: $showPhotoSheet) {
//            PhotoPicker(filter: .images, limit: 1) { results in
//                PhotoPicker.convertToUIImageArray(fromResults: results) { (imagesOrNil, errorOrNil) in
//                    if let error = errorOrNil {
//                        print(error)
//                    }
//                    if let images = imagesOrNil {
//                        if let first = images.first {
//                            print(first)
//                            image = first
//                            photos.insert(PhotoItem(image: Image(uiImage: first)), at: 1)
//                        }
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
            
//            PhotoPicker()
//        }
//        .sheet(isPresented: $showPreviewSheet) {
//
//            NavigationView {
//                VStack {
//
//                    HStack {
//
//                        Spacer(minLength: 300)
//
//                        Button(action: {
//                            showPreviewSheet = false
//                        }) {
//                            Image("ic-white-cross")
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 18, height: 18)
//                        }
//                        .frame(width: 44, height: 44)
//
//                    }
//                    .padding(.trailing, 8)
//                    .padding(.top, 8)
//                    .padding(.bottom, 5)
//
//                    if photosModel.selectedPhoto != nil {
//
//                        AsyncImage(url: photosModel.selectedPhoto?.url) { image in
//                            image
//                                .resizable()
//                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
//                                .frame(width: 343, height: 343)
//                                .cornerRadius(16)
//                                .padding(.bottom, 18)
//
//                        } placeholder: {
//                            ProgressView()
//                        }
//
//
//                    } else {
//                        Text("error")
//                    }
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
//
//                    Spacer(minLength: 28)
//
//                    NativeAdView()
//                        .frame(minWidth: UIScreen.main.bounds.width, minHeight: 60)
//                }
//                .background(Color(red: 30/255, green: 32/255, blue: 39/255))
//                .presentationDetents(
//                    [.height(UIScreen.main.bounds.height * 0.71)],
//                    selection: $settingsDetent
//                )
//            }
//        }

    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
