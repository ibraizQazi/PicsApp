//
//  ShareScreenView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 21/01/2023.
//

import SwiftUI

struct ShareScreenView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("placeholder-image")
                .resizable()
                .scaledToFill()
                .overlay(
                    
                    HStack {
                        
                        Image("ic-white-tick")
                            .resizable()
                            .scaledToFill()
                            .background(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .frame(width: 20, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .padding(.init(top: 10, leading: 16, bottom: 10, trailing: 6))
                        
                        Text("Photo Saved")
                            .font(.custom("Gilroy-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 16))
                        
                    }
                    .background(.white)
                    .frame(width: 160, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .frame(width: 343, height: 343)
                .padding(.init(top: 30, leading: 16, bottom: 30, trailing: 16))
            
            HStack(spacing: 17) {
                //socials
                
                Button(action: {
                    print("insta")
                }) {
                    Image("ic-insta")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.87, blue: 0.33),
                                 Color(red: 1, green: 0.33, blue: 0.24),
                                 Color(red: 0.78, green: 0.22, blue: 0.67)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .cornerRadius(17)
                
                Button(action: {
                    print("fb")
                }) {
                    Image("ic-fb")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
                .background(Color(red: 0.09, green: 0.47, blue: 0.95))
                .cornerRadius(17)
                
                Button(action: {
                    print("whatsapp")
                }) {
                    Image("ic-whatsapp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
                .background(Color(red: 0.11, green: 0.84, blue: 0.25))
                .cornerRadius(17)
                
                Button(action: {
                    print("snapchat")
                }) {
                    Image("ic-sc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
                .background(Color(red: 1, green: 0.95, blue: 0))
                .cornerRadius(17)
                
                Button(action: {
                    print("share")
                }) {
                    Image("ic-share")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
                .background(Color(red: 0.91, green: 1, blue: 1))
                .cornerRadius(17)
                
                
            }
            .frame(width: UIScreen.main.bounds.width, height: 64)
            .background(.black)
            
            HStack {
                NativeAdView()
            }
            .frame(width: UIScreen.main.bounds.width, height: 60)
            .background(.black)
            
        }.toolbar {
            HStack(spacing: 100) {
                Button(action: {
                    print("close screen")
                }) {
                    Image("ic-white-cross")
                        .resizable()
                        .scaledToFit()
                        .padding(.all, 12)
                }
                
                Text("Share")
                    .font(.custom("Gilroy-SemiBold", size: 24))
                    .foregroundColor(.white)
                
            }
            .frame(width: UIScreen.main.bounds.width, height: 64, alignment: .center)
            .background(.black)
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Color(red: 30/255, green: 32/255, blue: 39/255))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct ShareScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ShareScreenView()
    }
}
