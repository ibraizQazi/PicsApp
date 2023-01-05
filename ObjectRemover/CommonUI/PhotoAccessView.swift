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
                        Text("Enable Access to All Photos")
                            .font(.custom("Gilroy-Black", size: 22))
                            .foregroundColor(.black)
                        
                        Text("Allow All Photos access in settings to begin editing your photos")
                            .multilineTextAlignment(.center)
                            .font(.custom("Gilroy-Regular", size: 16))
                            .foregroundColor(.black)
                        
                        Button(action: openPermissions) {
                            Text("Give Access")
                                .font(.custom("Gilroy-Regular", size: 17))
                        }
                        .padding()
                        .frame(width: 283, height: 45)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .padding()
                    , alignment: .bottom
                )
        }
        .cornerRadius(15)

    }
}

struct PhotoAccessView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAccessView(openPermissions: {})
            .previewLayout(.sizeThatFits)
    }
}
