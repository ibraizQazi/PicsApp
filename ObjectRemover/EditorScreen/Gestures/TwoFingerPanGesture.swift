//
//  TwoFingerPanGesture.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 14/02/2023.
//

import Foundation
import SwiftUI

struct TwoFingerPanGesture: UIViewRepresentable {

    let delegate = GestureRecognizerDelegate()
    let coordinateSpace: CoordinateSpace = .local
    
//    @Binding var scale: CGFloat
    
    var drawCallback: ((CGPoint) -> Void)
    var drawEndedCallback: (() -> Void)
    var draggedCallback: ((CGPoint) -> Void)
    var dragEndedCallback: (() -> Void)
    var pinchedCallback: ((CGPoint, CGFloat) -> Void)
    var pinchEndedCallback: (() -> Void)
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(gesture:)))
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action:
                                                        #selector(Coordinator.handlePinchGesture(gesture:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self.delegate
        pinchGesture.delegate = self.delegate
        
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(coordinateSpace: coordinateSpace,
                           drawCallback: self.drawCallback,
                           drawEndedCallback: self.drawEndedCallback,
                           draggedCallback: self.draggedCallback,
                           dragEndedCallback: self.dragEndedCallback,
                           pinchedCallback: self.pinchedCallback,
                           pinchEndedCallback: self.pinchEndedCallback)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var translation: CGPoint = .zero
        let coordinateSpace: CoordinateSpace

        var drawCallback: ((CGPoint) -> Void)
        var drawEndedCallback: (() -> Void)
        var draggedCallback: ((CGPoint) -> Void)
        var dragEndedCallback: (() -> Void)
        var pinchedCallback: ((CGPoint, CGFloat) -> Void)
        var pinchEndedCallback: (() -> Void)
        
        var startingDistance: CGFloat? = nil
        var isMagnifying = false
        var startingMagnification: CGFloat? = nil
        var newMagnification: CGFloat = 1.0
        

        init(coordinateSpace: CoordinateSpace,
             drawCallback: @escaping ((CGPoint) -> Void),
             drawEndedCallback: @escaping (() -> Void),
             draggedCallback: @escaping ((CGPoint) -> Void),
             dragEndedCallback: @escaping (() -> Void),
             pinchedCallback: @escaping ((CGPoint, CGFloat) -> Void),
             pinchEndedCallback: @escaping (() -> Void)) {
            self.coordinateSpace = coordinateSpace
            self.draggedCallback = draggedCallback
            self.dragEndedCallback = dragEndedCallback
            self.pinchedCallback = pinchedCallback
            self.pinchEndedCallback = pinchEndedCallback
            self.drawCallback = drawCallback
            self.drawEndedCallback = drawEndedCallback
        }
        
        @objc func handlePinchGesture(gesture: UIPinchGestureRecognizer) {
            print("handlePinchGesture")
            guard let view = gesture.view else {
                return
            }
            
            let currentScale = 1
            switch gesture.state {
            case .began, .changed:
                print("began")
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                pinchedCallback(pinchCenter, gesture.scale)
            case .ended:
                pinchEndedCallback()
            case .possible, .cancelled, .failed:
                print("cancelled/failed pinch gesture")
            }
        }
        
        @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
            print("handlePanGesture")
            if gesture.state == .ended {
                self.dragEndedCallback()
                self.pinchEndedCallback()
                self.drawEndedCallback()
                startingDistance = nil
                isMagnifying = false
                startingMagnification = nil
                newMagnification = 1.0
            } else {
                self.draggedCallback(gesture.translation(in: gesture.view))
            }
            
            var touchLocations: [CGPoint] = []
            for i in 0..<gesture.numberOfTouches {
                touchLocations.append(gesture.location(ofTouch: i, in: gesture.view))
            }
            
            if touchLocations.count == 2 {
                let distanceVector = ((touchLocations[0].x - touchLocations[1].x), (touchLocations[0].y - touchLocations[1].y))
                let distance = sqrt(distanceVector.0 * distanceVector.0 + distanceVector.1 * distanceVector.1)
                
                guard startingDistance != nil else { startingDistance = distance; return }
                guard distance - startingDistance! > 30 || distance - startingDistance! < -30 || isMagnifying else { return }
                isMagnifying = true;
                
//                if startingMagnification == nil {
//                    startingMagnification = distance / 100
//                    pinchedCallback(1)
//                } else {
//                    let magnification = distance / 100
//                    newMagnification = magnification / startingMagnification!
//                    pinchedCallback(newMagnification)
//                }
            }
            
            if touchLocations.count == 1 {
                switch gesture.state {
                    case .began:
                        let firstTouch = gesture.location(in: gesture.view)
                        print("draw first touch \(firstTouch)")
                    case .changed:
                        let touch = gesture.location(in: gesture.view)
                        let translation = gesture.translation(in: gesture.view)
                    print("changed : touch = \(touch.x)")
                    print("changed: translation = \(translation.x)")
                        drawCallback(touch)
                    case .ended:
                        drawEndedCallback()
                    case .possible,.cancelled,.failed:
                        drawEndedCallback()
                }
            }
            
        }
    }
    
    class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }

}





