//
//  PhotoItem.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 05/01/2023.
//

import SwiftUI

struct EditorView: View {
    
//    @State private var maskLayer = CAShapeLayer()
    @State private var path = Path()
    @Binding var photo: PhotoItem
    
    @State private var lines = [Line]()
    @State private var deletedLines = [Line]()
    
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 1
    
    let engine = DrawingEngine()
    @State private var showConfirmation: Bool = false
    
    let uiImageAsset = UIImage(named: "permission-asset")
    
    var body: some View {
        VStack {
    
            HStack {
                ColorPicker("line color", selection: $selectedColor)
                    .labelsHidden()
                Slider(value: $selectedLineWidth, in: 1...20) {
                    Text("linewidth")
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
                    showConfirmation = true
                }) {
                    Text("Delete")
                }.foregroundColor(.red)
                    .confirmationDialog(Text("Are you sure you want to delete everything?"), isPresented: $showConfirmation) {
                        
                        Button("Delete", role: .destructive) {
                            lines = [Line]()
                            deletedLines = [Line]()
                        }
                    }
                
            }.padding()
            
            ZStack{
                Image("permission-asset")
//
                ForEach(lines){ line in
                    DrawingShape(points: line.points)
                        .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                }
//                Image(uiImage: applyMask(to: uiImageAsset!)!)
//                    .scaledToFit()
//                    .frame(width: 300, height: 450)
//                    .border(Color.blue, width: 4)
            }
            .padding()
            .border(Color.red, width: 4)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let newPoint = value.location
                        if value.translation.width + value.translation.height == 0 {
                            //TODO: use selected color and linewidth
                            lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                            
                        } else {
                            let index = lines.count - 1
                            lines[index].points.append(newPoint)
                        }
                    
                }
            ).onEnded({ value in
                if let last = lines.last?.points, last.isEmpty {
                    lines.removeLast()
                }
            })
                     
            )

            
        }
    
    }

    func applyMask(to image: UIImage) -> UIImage? {
        let renderer = MaskRenderer(size: image.size, scale: image.scale)
        guard let imageMask = renderer.image(actions: { context in
            let rect = CGRect(origin: .zero, size: renderer.sizeInPixels)
                .insetBy(dx: 0, dy: renderer.sizeInPixels.height / 4)
            let path = UIBezierPath(ovalIn: rect)
            context.addPath(path.cgPath)
            context.setFillColor(gray: 1, alpha: 1)
            context.drawPath(using: .fillStroke)
        }) else { return nil }
        return image.withMask(imageMask)
    }
    
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(photo: .constant(PhotoItem(image: Image("permission-asset"))))
    }
}
