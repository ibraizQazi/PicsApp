//
//  EditorScreenView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 19/01/2023.
//

import SwiftUI

struct EditorScreenView: View {
    
    @State private var isSaveActive = false
    @State private var isPaintSelected = true
    @State private var isEraseSelected = false
    
    @State private var showDialog = false
    
    @State var brushSize : Float = 0.0
    
//    @State private var progress = 50.0
//
//    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image("placeholder-image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 375, height: 476)
                    .edgesIgnoringSafeArea([.horizontal])
                    .overlay(
                        HStack(spacing: 220) {
                            //overlay btns
                            
                            HStack(spacing: 18) {
                                
                                Button(action: {
                                    print("undo")
                                }) {
                                    Image("ic-undo-inactive")
                                        .resizable()
                                        .frame(width: 13, height: 11)
                                        .scaledToFit()
                                    
                                }
                                .frame(width: 36, height: 36)
                                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                                .contentShape(Circle())
                                .cornerRadius(100)
                                
                                Button(action: {
                                    print("redo")
                                }) {
                                    Image("ic-redo-inactive")
                                        .resizable()
                                        .frame(width: 13, height: 11)
                                        .scaledToFit()
                                    
                                }
                                .frame(width: 36, height: 36)
                                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                                .contentShape(Circle())
                                .cornerRadius(100)
                                
                                
                            }
                            
                            Button(action: {
                                print("compare")
                                
//                                showDialog = true
                            }) {
                                Image("ic-compare")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 18, height: 18)
                                
                            }
                            .frame(width: 36, height: 36)
                            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            .contentShape(Circle())
                            .cornerRadius(100)
                            
                        }
                            .frame(maxHeight: 36)
                            .padding(.bottom, 12)
                        , alignment: .bottom
                    )
                
                
                HStack(spacing: 24) {
                    //brush ctrls
                    
                    HStack(spacing: 7) {
                        // brush btns
                        Button(action: {
                            print("paint toggle")
                            isPaintSelected.toggle()
                        }) {
                            if isPaintSelected {
                                
                                VStack(alignment: .center, spacing: 7) {
                                
                                    Image("ic-paint-selected")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    
                                    Text("Paint")
                                        .font(.custom("Gilroy-SemiBold", size: 10))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.7, green: 1, blue: 0.67),
                                                         Color(red: 0.07, green: 1, blue: 0.97)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                }
                                
                            } else {
                                VStack(alignment: .center, spacing: 7) {
                                    
                                    Image("ic-paint-unselected")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    
                                    Text("Paint")
                                        .font(.custom("Gilroy-SemiBold", size: 10))
                                        .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                                    
                                }
                            }
                        }
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            print("erase toggle")
                            isEraseSelected.toggle()
                        }) {
                            if isEraseSelected {
                                
                                VStack(alignment: .center, spacing: 7) {
                                    
                                    Image("ic-erase-selected")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    
                                    Text("Erase")
                                        .font(.custom("Gilroy-SemiBold", size: 10))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.7, green: 1, blue: 0.67),
                                                         Color(red: 0.07, green: 1, blue: 0.97)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                            } else {
                                
                                VStack(alignment: .center, spacing: 7) {
                                    
                                    Image("ic-erase-unselected")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    
                                    Text("Erase")
                                        .font(.custom("Gilroy-SemiBold", size: 10))
                                        .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))

                                }
                                
                            }
                        }
                        .frame(width: 50, height: 50)
                    }
                    
                    
                    //slider
                    Slider(value: $brushSize,
                           in: 0...100,
                           step: 5) { didChange in
                        print("Did change: \(didChange)")
                    }
                           .tint(Color(red: 0.7, green: 1, blue: 0.67))
                           .frame(width: 200)
                           .padding(.trailing, 18)
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: 64)
                .background(.black)
                
                HStack {
                    //remove btn
                    
                    Button(action: {
                        print("remove object")
                    }) {
                        HStack(spacing: 11) {
                            Image("ic-tick-inactive")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 10)
                            
                            Text("Remove")
                                .font(.custom("Gilroy-SemiBold", size: 16))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.71))
                        }
                    }
                    .frame(width: 158, height: 42)
                    .background(Color(red: 0.2, green: 0.21, blue: 0.22))
                    .cornerRadius(16)
                }
                .frame(width: UIScreen.main.bounds.width, height: 67)
                .background(.black)
                
                HStack {
                    //ad view
                    NativeAdView()
                }
                .frame(width: UIScreen.main.bounds.width, height: 60)
                .background(.black)
                
            }
            .toolbar {
                
                HStack(alignment: .center) {
                    
                    Button(action: {
                        print("go home")
                    }) {
                        Image("ic-home")
                            .resizable()
                            .frame(width: 20, height: 22)
                            .scaledToFit()
                    }
                    .frame(width: 44, height: 44)
                    .padding(.leading, 16)
                    
                    Spacer(minLength: 8)
                    
                    if isSaveActive {
                        
                        Button(action: {
                            print("Save result")
                            isSaveActive.toggle()
                        }) {
                            
                            HStack(spacing: 0) {
                                
                                Image("ic-download-active")
                                    .resizable()
                                    .frame(width: 14, height: 16)
                                    .scaledToFill()
                                    .padding(.init(top: 6.5, leading: 17, bottom: 6.5, trailing: 0))
                                
                                Text("Save")
                                    .font(.custom("Gilroy-Bold", size: 14))
                                    .frame(width: 52, height: 26)
                                    .foregroundColor(.black)
                                    .padding(.trailing, 20)
                            }
                            
                        }
                        .background(
                            LinearGradient(
                                colors: [Color(red: 179/255, green: 1, blue: 171/255),
                                         Color(red: 18/255, green: 1, blue: 247/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(maxWidth: 91, maxHeight: 29)
                        .cornerRadius(16)
                        .padding(.trailing, 16)
                        
                    } else {
                        
                        Button(action: {
                            print("Save result")
                            isSaveActive.toggle()
                        }) {
                            
                            HStack(spacing: 0) {
                                
                                Image("ic-download-inactive")
                                    .resizable()
                                    .frame(width: 14, height: 16)
                                    .scaledToFill()
                                    .padding(.init(top: 6.5, leading: 17, bottom: 6.5, trailing: 0))
                                
                                Text("Save")
                                    .font(.custom("Gilroy-Bold", size: 14))
                                    .frame(width: 52, height: 26)
                                    .foregroundColor(Color(red: 0.36, green: 0.36, blue: 0.37))
                                    .padding(.trailing, 20)
                                
                            }
                            
                        }
                        .background(
                            Color(red: 0.76, green: 0.76, blue: 0.76)
                        )
                        .frame(maxWidth: 91, maxHeight: 29)
                        .cornerRadius(16)
                        .padding(.trailing, 16)
                    }
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: 64, alignment: .center)
                .background(.black)
                
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color(red: 30/255, green: 32/255, blue: 39/255))
            .edgesIgnoringSafeArea([.horizontal])
            .padding(.bottom, 20)
            
            if showDialog {
                ProgressDialogView(openAd: {showDialog = false})
                    .frame(width: 327, height: 262, alignment: .center)
            }
        }
    }
}

struct EditorScreenView_Previews: PreviewProvider {
    static var previews: some View {
        EditorScreenView()
    }
}
