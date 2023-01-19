//
//  ProgressDialogView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 18/01/2023.
//

import SwiftUI

struct ProgressDialogView: View {

    @State private var progress = 50.0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var openAd: ()->Void
    
    var body: some View {
        VStack {
            Text(" \(Int(progress))% Processing Image ")
                .foregroundColor(.white)
                .font(.custom("Gilroy-SemiBold", size: 16))
                .padding(.top, 35)
            
            ProgressView(value: progress, total: 100)
                .onReceive(timer) { _ in
                    if progress < 100 {
                        progress += 2
                    }
                }
                .accentColor(Color(red: 179/255, green: 1, blue: 171/255))
                .foregroundColor(.red)
                .cornerRadius(100)
                .padding(.init(top: 12, leading: 30, bottom: 40, trailing: 30))
            
            // ad view
            Image("native-ad-placeholder-image")
                .resizable()
                .scaledToFill()
                .frame(width:345, height: 56)
            
            Button(action: openAd) {
                Text("Open")
                    .font(.custom("Gilroy-SemiBold", size: 16))
                    .foregroundColor(.black)
            }
            
            .frame(width: 283, height: 45)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.7, green: 1, blue: 0.67),
                             Color(red: 0.07, green: 1, blue: 0.97)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .padding(.init(top: 12, leading: 28, bottom: 20, trailing: 28))
            
        }
        .background(Color(red: 0.14, green: 0.14, blue: 0.16))
        .cornerRadius(18)
        
    }
}

struct ProgressDialogView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressDialogView(openAd: {})
            .previewLayout(.sizeThatFits)
    }
}
