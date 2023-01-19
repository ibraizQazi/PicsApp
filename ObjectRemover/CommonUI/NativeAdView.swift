//
//  NativeAdView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 12/01/2023.
//

import SwiftUI

struct NativeAdView: View {
    var body: some View {
        VStack {
            Image("native-ad-placeholder-image")
                .resizable()
                .scaledToFill()
                .frame(width:345, height: 56)
//                .padding(12)
        }
        
    }
}

struct NativeAdView_Previews: PreviewProvider {
    static var previews: some View {
        NativeAdView()
    }
}
