//
//  PackageBtn.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 29/01/2023.
//

import SwiftUI

struct PackageBtn: View {
    let packageTime = "WEEKLY"
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(packageTime)")
                .frame(width: 155, height: 30)
                .border(.white, width: 1)
                .cornerRadius(18, corners: [.topRight, .topLeft])
        }
    }
}

struct PackageBtn_Previews: PreviewProvider {
    static var previews: some View {
        PackageBtn()
    }
}
