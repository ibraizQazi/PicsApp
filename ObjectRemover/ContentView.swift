//
//  ContentView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 15/12/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LottieLoaderView(lottieFile: "qr-code-loader")
            .frame(width: 300, height: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
