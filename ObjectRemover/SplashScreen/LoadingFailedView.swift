//
//  LoadingFailedView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 12/01/2023.
//

import SwiftUI

struct LoadingFailedView: View {
    var body: some View {
        VStack {
            
            Text("Loading Failed")
                .font(.custom("Gilroy_Regular", size: 20))
            Spacer(minLength: 8)
            Text("It seems lke you are not connected to the network.")
                .font(.custom("Gilroy_Regular", size: 12))
            Text("Please check your internet connection and try again..")
                .font(.custom("Gilroy_Regular", size: 12))
            Spacer(minLength: 16)
            Button(action: {}) {
                Text("Try Again")
                    .font(.custom("Gilroy-Regular", size: 17))
            }
            .padding()
            .frame(width: 283, height: 45)
            .background(.black)
            .foregroundColor(.white)
            .cornerRadius(16)
        }.frame(height: 42)
    }
}

struct LoadingFailedView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingFailedView()
    }
}
