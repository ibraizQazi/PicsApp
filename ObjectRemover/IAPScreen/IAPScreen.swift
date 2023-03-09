//
//  IAPScreen.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 25/01/2023.
//

import SwiftUI

struct IAPScreen: View {
    
    @State private var ctaText: String = ""
    
    @State private var isSelected = false
    let package = "WEEKLY"
    let price = "$20"
    let period = "week"
    
    let colorN30 = Color(red: 0.93, green: 0.93, blue: 0.93)
    
    let selectedBg = Color(red: 1, green: 0.8, blue: 0.05)
    
    let colorN800 = Color(red: 0.12, green: 0.13, blue: 0.15)
    
    let unSelectedBg = Color(red: 0, green: 0, blue: 0, opacity: 0.7)
    
    var body: some View {
        Image("bg-iap")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
            .overlay(
                VStack {
                    HStack{
                        // Top buttons
                        Button(action: {
                            print("cross tapped")
                        }) {
                            Image("ic-white-cross")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                        }
                        .frame(width: 28, height: 28)
                        .background(Color(red: 0.24, green: 0.24, blue: 0.27))
                        .clipShape(Circle())
                        .padding(.leading, 16)
                        .border(.red, width: 1)
                        
                        Spacer()
                        
                        Button(action: {
                            print("restore tapped")
                        }) {
                            Text("RESTORE")
                                .font(.custom("Gilroy-SemiBold", size: 13))
                                .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.68))
                                .padding(.init(top: 2, leading: 10, bottom: 2, trailing: 10))
                            
                        }
                        .frame(width: 78, height: 34)
                        .background(Color(red: 0.07, green: 0.08, blue: 0.11))
                        .cornerRadius(100)
                        .padding(.trailing, 16)
                        .border(.red, width: 1)

                    }
                    .padding(.bottom, 50)
                    
                    
                    HStack(spacing: 0) {
                        // Title
                        Text("SnapErase")
                            .font(.custom("Gilroy-Bold", size: 26))
                            .foregroundColor(.white)
                            .padding(.trailing, 16)
                        
                        Text("PRO")
                            .font(.custom("Gilroy-Bold", size: 14))
                            .frame(width: 52, height: 26)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 179/255, green: 1, blue: 171/255),
                                             Color(red: 18/255, green: 1, blue: 247/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    }
                    .padding(.bottom, 18)
                    
                    
                    VStack(alignment: .leading) {
                        // Feature List
                        HStack {
                            Image("ic-green-tick-br")
//                                .frame(width: 12, height: 9)
                            Text("Ad Free Experience")
                                .font(.custom("Gilroy-SemiBold", size: 17))
                                .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                                
                        }
                        .padding(.bottom, 17)
                        
                        HStack {
                            Image("ic-green-tick-br")
                            //                                .frame(width: 12, height: 9)
                            Text("Remove object remover watermark")
                                .font(.custom("Gilroy-SemiBold", size: 17))
                                .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                        }
                    }
                    .frame(width: 339, height: 124)
                    .background(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                    .cornerRadius(24)
                    .padding(.bottom, 127)
                    
                    
                    HStack(alignment: .top) {
                        // package btns
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                self.isSelected = true
                                print("unselected state")
                            }) {
                            
                                VStack(spacing: 0) {
                                    Text("\(package)")
                                        .frame(width: 155, height: 30)
                                        .font(.custom("Gilroy-Bold", size: 17))
                                        .foregroundColor(colorN30)
                                        .background(unSelectedBg)
                                        .overlay(
                                            Rectangle().fill(colorN30).frame(height: 1.0),     // << here !!
                                            alignment: .bottom
                                        )

                                    
                                    VStack(spacing: 0) {
                                        Text("\(price)")
                                            .font(.custom("Gilroy-Bold", size: 34))
                                            .foregroundColor(colorN30)
                                        
                                        Text("/\(period)")
                                            .font(.custom("Gilroy-SemiBold", size: 14))
                                            .foregroundColor(colorN30)
                                    }
                                    .padding(.bottom, 25)
                                    .frame(width: 155, height: 130)
                                    .background(unSelectedBg)
    //                                .border(.white, width: 1)
                                    
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(colorN30, lineWidth: 1)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                )
                            }
                            .padding(.bottom, 7)
                            
                            Text("7-Day Free Trial")
                                .font(.custom("Gilroy-Medium", size: 13))
                                .foregroundColor(selectedBg)
                        }
                        .padding(.trailing, 29)
                        
                        
                        Button(action: {
                            //lifetime
                            print("selected state")
                        }) {
                            
                            VStack(spacing: 0) {
                                
                                Text("LIFETIME")
                                    .frame(width: 155, height: 30)
                                    .font(.custom("Gilroy-Bold", size: 17))
                                    .foregroundColor(.white)
                                    .background(colorN800)
                                    .overlay(
                                        Rectangle().fill(colorN800).frame(height: 1.0),     // << here !!
                                        alignment: .bottom
                                    )
                                
                                
                                VStack(spacing: 0) {
                                    Text("\(price)")
                                        .font(.custom("Gilroy-Bold", size: 34))
                                        .foregroundColor(.black)
                                    
                                    Text("SAVE 56%")
                                        .font(.custom("Gilroy-SemiBold", size: 14))
                                        .foregroundColor(.white)
                                        .padding(.init(top: 3, leading: 9, bottom: 3, trailing: 9))
                                        .background(.black)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        )
                                }
                                .padding(.bottom, 25)
                                .frame(width: 155, height: 130)
                                .background(selectedBg)
                                //                                .border(.white, width: 1)
                                
                            }
                            .overlay(
                                Image("ic-black-tick")
                                    .resizable()
                                    .frame(width:14, height: 10, alignment: .topTrailing)
                                    .offset(x: 60, y: -34)
                                
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selectedBg, lineWidth: 4)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                        }
                    }
                    .padding(.bottom, 40)
                    
                    HStack(spacing: 12) {
                        
                        Button(action: {
                            print("go terms page")
                        }){
                            Text("Terms of Service")
                                .font(.custom("Gilroy-Medium", size: 14))
                                .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                                .underline()
                                
                        }
                        
                        Image("ic-seperator")
                            .resizable()
                            .scaledToFit()
                        
                        Button(action: {
                            print("go privacy page")
                        }){
                            Text("Privacy Policy")
                                .font(.custom("Gilroy-Medium", size: 14))
                                .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                                .underline()
                        }
                        
                    }
                    .padding(.bottom, 22)
                    
                    
                    Button(action: {
                        print("go to app store")
                    }) {
                        Text("Continue")
                            .font(.custom("Gilroy-Bold", size: 20))
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width, height: 140, alignment: .top)
                            .padding(.top, 18)
                            .background(selectedBg)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 36, style: .continuous)
                            )
                    }
                    
                    
                }

            )

    }
}

struct IAPScreen_Previews: PreviewProvider {
    static var previews: some View {
        IAPScreen()
    }
}
