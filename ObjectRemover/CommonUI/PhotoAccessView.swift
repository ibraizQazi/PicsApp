//
//  PhotoAccessView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 27/12/2022.
//

import SwiftUI

struct PhotoAccessView: View {
    
    var openPermissions: ()->Void
    
    var body: some View {
        VStack {
            Image("permission-asset")
                .overlay(
                    VStack {
                        VStack {
                            Text("Enable Access to All Photos")
                                .font(.custom("Gilroy-Bold", size: 22))
                                .foregroundColor(.black)
                                .frame(height: 27)
                                
                            
                            Text("Allow All Photos access in settings to \n begin editing your photos")
                                .multilineTextAlignment(.center)
                                .font(.custom("Gilroy-Medium", size: 16))
                                .lineSpacing(0)
                                .foregroundColor(Color(red: 73/255, green: 74/255, blue: 80/255))
                                
                        }.padding(.bottom, 24)
                        
                        Button(action: openPermissions) {
                            Text("Give Access")
                                .font(.custom("Gilroy-SemiBold", size: 17))
                                .foregroundColor(.black)
                        }
                        
                        .frame(width: 283, height: 45)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 179/255, green: 1, blue: 171/255),
                                         Color(red: 18/255, green: 1, blue: 247/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                        .padding(.bottom, 44)
                    , alignment: .bottom
                    
                )
        }
        .frame(height: 450)
        .cornerRadius(24)

    }
}

struct PhotoAccessView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAccessView(openPermissions: {})
            .previewLayout(.sizeThatFits)
    }
}
