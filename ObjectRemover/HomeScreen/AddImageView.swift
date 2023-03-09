//
//  AddImageView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 01/02/2023.
//

import SwiftUI

struct AddImageView: View {
    var body: some View {
        VStack(spacing: 18) {
            
            Image("ic-import")
                .resizable()
                .scaledToFill()
                .frame(width: 21.5, height: 21.5)
            
            
            Text("IMPORT PHOTO")
                .font(.custom("Gilroy-Bold", size: 12))
                .foregroundColor(.white)
                .tracking(-0.2)
        }
        .frame(minWidth: 108, maxWidth: 108,minHeight: 108 ,maxHeight: 108)
        .background(Color(red: 0.07, green: 0.08, blue: 0.11))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 2)
        )
        .cornerRadius(10.0)
    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView()
    }
}
