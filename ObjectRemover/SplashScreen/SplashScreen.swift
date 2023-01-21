//
//  SplashView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 26/12/2022.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive: Bool = false
        
    var body: some View {
        
        NavigationView {
            ZStack {
                if self.isActive {
//                    HomeView()
                    EditorScreenView()
                    //                EditorView(photo: .constant(Photo(image: UIImage(named: "permission-asset")!)))
                } else {
                    VStack {
                        
                        Spacer(minLength: 250)
                        
                        VStack {
                            Image("splash-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 72, maxWidth: 72, minHeight: 72, maxHeight: 72)
                            
                            Spacer(minLength: 16)
                            
                            Text("Object Remover")
                                .font(.custom("Gilroy-Bold", size: 24))
                                .tracking(-0.5)
                            
                        }.frame(maxWidth: 180, maxHeight: 120)
                
                        Spacer(minLength: 260)
                        
                        VStack {
                            LottieLoaderView(lottieFile: "qr-code-loader")
                                .frame(minWidth: 78, maxWidth: 78, minHeight: 78, maxHeight: 78)
                            
                            Spacer(minLength: 8)
                            
                            Text("AI model is warming up...")
                                .font(.custom("Gilroy-SemiBold", size: 14))
                            
                        }.frame(maxWidth: 160, maxHeight: 160)
                            .padding(.bottom, 70)
                        
                            
                    }
                    .background(.white)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
