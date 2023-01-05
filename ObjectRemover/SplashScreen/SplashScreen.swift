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
                               
        ZStack {
            if self.isActive {
                HomeView()
            } else {
                LottieLoaderView(lottieFile: "qr-code-loader")
                    .frame(width: 300, height: 400)
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

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
