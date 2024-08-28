//
//  HomeView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 26/12/2022.
//

import SwiftUI
import PhotosUI
import Photos
import PermissionsSwiftUIPhoto
import os.log

struct HomeView: View {
   
    @StateObject var photosCollection = PhotoCollection(smartAlbum: .smartAlbumRecentlyAdded)
        
    @State var navigationStateManager = NavigationStateManager()
    
    @SceneStorage("navigationState") var navigationStateData: Data?

    @State var previewAsset: PhotoAsset?
    
    @State var showModal = false
    @State var showSettingAlert = false
    
    @State var photoPermission: PHAuthorizationStatus = .notDetermined
    
    var body: some View {

        NavigationStack(path: $navigationStateManager.editorPath) {
            
            if photoPermission == .limited {
                
                PartialAccessGalleryGrid(photoCollection: PhotoCollection(smartAlbum: .smartAlbumRecentlyAdded), previewAsset: $previewAsset)
                    .navigationDestination(for: EditorState.self) { state in
                        switch state {
                        case .remover(_):
                            EditorView()
                        case .cloner(_):
                            EditorView()
                        case .save:
                            ShareScreenView()
                        case .purchase:
                            IAPScreen()
                        }
                    }
                
            } else if photoPermission == .authorized {
                
                AllAccessGalleryGrid(photoCollection: PhotoCollection(smartAlbum:.smartAlbumUserLibrary), previewAsset: $previewAsset)
                    .navigationDestination(for: EditorState.self) { state in
                        switch state {
                        case .remover(_):
//                        case .remover(let photoAsset):
                            EditorView()
                        case .cloner(_):
                            EditorView()
                        case .save:
                            ShareScreenView()
                        case .purchase:
                            IAPScreen()
                        }
                    }
                
            } else {
                
                PhotoAccessView(openPermissions: {
                    if photoPermission == .notDetermined {
                        showModal.toggle()
                        logger.debug("open permissions")
                    } else if photoPermission == .denied {
                        showSettingAlert.toggle()
                        logger.debug("open settings")
                    }
                })
                .JMModal(showModal: $showModal, for: [.photo], autoDismiss: true)
                .frame(width: 343, height: 587)
                .padding(.horizontal, 16)
                .background(Color(red:11/255,green:12/255,blue:17/255))
                
                
                NativeAdView()
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 114, maxHeight: 114)
                    .padding(.top, 0)
                    .padding(.bottom, 100)
            }
            
        }
        .environmentObject(photosCollection)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            let perms = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            photoPermission = perms
            print("onAppear: permission = \(photoPermission)")
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
                    navigationStateManager.goToPurchase()
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
        .sheet(item: $previewAsset) { asset in
            PreviewSheet(previewAsset: $previewAsset)
        }
        .alert(isPresented: $showSettingAlert) {
            Alert (title: Text("Photo access required!"),
                   message: Text("Go to Settings?"),
                   primaryButton: .default(Text("Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }),
                   secondaryButton: .default(Text("Cancel")))
        }
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

    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.trinium.ai.snaperaser", category: "HomeView")
