//
//  PhotoItem.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 05/01/2023.
//

import SwiftUI

struct EditorView: View {
    
//    @State private var maskLayer = CAShapeLayer()
    @Environment(\.scenePhase) var scenePhase
    
    @State private var lines = [Line]()
    @State private var deletedLines = [Line]()
    
    @State private var selectedColor: Color = .black.opacity(0.5)
    @State private var selectedLineWidth: CGFloat = 10
    
    let engine = DrawingEngine()
    @State private var showConfirmation: Bool = false
   
    @State var binaryImage: Data?
    @State var testImage: UIImage = UIImage(named: "grizzly")!
    
    @GestureState private var scaleState: CGFloat = 1
    @GestureState private var offsetState = CGSize.zero
    
    @State private var dragOffset = CGSize.zero
    @State private var scale: CGFloat = 1

    func resetStatus() {
        self.dragOffset = CGSize.zero
        self.scale = 1
    }
    
    init(){
        resetStatus()
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($scaleState) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                print("mag gesture value: \(value)")
                scale *= value
            }
    }

    
    var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged({ value in
                let newPoint = value.location
                if value.translation.width + value.translation.height == 0 {
                    //TODO: use selected color and line width
                    lines.append(Line(points: [newPoint],
                                      color: selectedColor, lineWidth: selectedLineWidth))
                } else {
                    let index = lines.count - 1
                    lines[index].points.append(newPoint)
                }
                
            }).onEnded({ value in
                if let last = lines.last?.points, last.isEmpty {
                    lines.removeLast()
                }
                
            })
    }
    
    
    var body: some View {
        GeometryReader { geo in
            
            let orgImage = Image(uiImage: testImage)
            
            
            VStack {
                
                HStack {
                    ColorPicker("line color", selection: $selectedColor)
                        .labelsHidden()
                    Slider(value: $selectedLineWidth, in: 10...100) {
                        Text("line width")
                    }.frame(maxWidth: 100)
                    Text(String(format: "%.0f", selectedLineWidth))
                    
                    Spacer()
                    
                    Button {
                        let last = lines.removeLast()
                        deletedLines.append(last)
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .imageScale(.large)
                    }.disabled(lines.count == 0)
                    
                    Button {
                        let last = deletedLines.removeLast()
                        
                        lines.append(last)
                    } label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                            .imageScale(.large)
                    }.disabled(deletedLines.count == 0)
                    
                    Button(action: {
                        transformCanvas(geoSize: geo.size)
                    }) {
                        Text("Save")
                    }
                    .foregroundColor(.green)
                    
                    Button(action: {
                        showConfirmation = true
                    }) {
                        Text("Delete")
                    }.foregroundColor(.red)
                        .confirmationDialog(Text("Are you sure you want to delete everything?"), isPresented: $showConfirmation) {
                            
                            Button("Delete", role: .destructive) {
                                deletedLines = [Line]()
                                lines = [Line]()
                                binaryImage = nil
                                
                            }
                        }
                }
                .background(.blue.opacity(0.5))
                .padding()
                
                
                if binaryImage != nil {
                    Image(uiImage: UIImage(data: binaryImage!)!)
                        .resizable()
                        .scaledToFit()
                } else {
                                        
//                    ZStack {
                        Canvas { context, size in

                            print("geo size: \(geo.size.width) , \(geo.size.height)")

                            print("canvas size: \(size.width) , \(size.height)")
                            
                            let assetSize = getScaledImageSize(originalSize: testImage.size, targetSize: size)
                                                    
                            context.draw(orgImage, in: CGRect(origin: .zero, size: assetSize))
                            
                            for line in lines {
                                
                                let path = engine.createPath(for: line.points)
                                
                                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                                
                            }
                        }
//                        .scaleEffect(scale)
//                        .zoomable(scale: $scale, offset: $dragOffset)
//                        .offset(x: dragOffset.width + offsetState.width, y: dragOffset.height + offsetState.height)
                        .clipped()
                        .frame(width: geo.size.width, height: geo.size.height)
//                        .simultaneousGesture(drawGesture)
//                        .gesture(drawGesture)
                        
//                        TwoFingerPanGesture(
//                            drawCallback: { value in
//                                print("drawCallback \(value)")
//
//                            },
//                            drawEndedCallback: {
//                                print("draggedEnded")
//                                if let last = lines.last?.points, last.isEmpty {
//                                    lines.removeLast()
//                                }
//                            },
//                            draggedCallback: { _ in  },
//                            dragEndedCallback: {  },
//                            pinchedCallback: { center,newScale  in
//                                scale *= newScale
//                                dragOffset = center
//                            },
//                            pinchEndedCallback: {
//
//                            }
//                        )
                        
//                    }
                    
                }
            }
            .border(.blue, width: 2)
        }
    
    }

    @MainActor func transformCanvas(geoSize: CGSize) {
//        let orgImage = UIImage(named: "placeholder-image")
        let orgImage = UIImage(named: "grizzly")

        let imageAsset = Image(uiImage: orgImage!)
        
        let imageRenderer = ImageRenderer(content:  Canvas { context, size in
            print("renderer canvas size: \(geoSize.width) , \(geoSize.height)")

            let assetSize = getScaledImageSize(originalSize: orgImage!.size, targetSize: geoSize)
            
            context.draw(imageAsset, in: CGRect(origin: .zero, size: assetSize))
            
            for line in lines {
                
                let path = engine.createPath(for: line.points)
                
                context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                
            }
        }.frame(width: geoSize.width, height: geoSize.height).border(.yellow, width: 2))
        
        if let img = imageRenderer.cgImage {
            let uiImage = UIImage(cgImage: img)
            print("result image size: \(uiImage.size.width) , \(uiImage.size.height)")
            binaryImage = uiImage.pngData()
        }
    }
    
    private func getScaledImageSize(originalSize: CGSize, targetSize: CGSize) -> CGSize {
        let widthRatio = CGFloat(targetSize.width) / originalSize.width
        let heightRatio = CGFloat(targetSize.height) / originalSize.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        return CGSize(
            width: originalSize.width * scaleFactor,
            height: originalSize.height * scaleFactor
        )
    }

}


struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
