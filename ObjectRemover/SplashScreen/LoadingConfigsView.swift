//
//  LoadingConfigsView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 12/01/2023.
//

import SwiftUI

struct LoadingConfigsView: View {
    var body: some View {
        VStack {
            LottieLoaderView(lottieFile: "qr-code-loader")
                .frame(minWidth: 78, maxWidth: 78, minHeight: 78, maxHeight: 78)
            
            Spacer(minLength: 12)
            
            Text("Loading configuration files. Please wait.")
                .font(.custom("Gilroy_Regular", size: 12))
        }.frame(height:104)
    }
}

struct LoadingConfigsView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingConfigsView()
    }
}
