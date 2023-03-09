//
//  DraggableView.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 17/02/2023.
//

import SwiftUI

// Constrains a value between the limits
func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
    min(maxValue, max(minValue, value))
}

// UIView that relies on UIPinchGestureRecognizer to detect scale, anchor point and offset
class ZoomableView: UIView {
    let minScale: CGFloat
    let maxScale: CGFloat
    let scaleChange: (CGFloat) -> Void
    let anchorChange: (UnitPoint) -> Void
    let offsetChange: (CGSize) -> Void
    
    private var scale: CGFloat = 1 {
        didSet {
            scaleChange(scale)
        }
    }
    private var anchor: UnitPoint = .center {
        didSet {
            anchorChange(anchor)
        }
    }
    private var offset: CGSize = .zero {
        didSet {
            offsetChange(offset)
        }
    }
    
    private var isPinching: Bool = false
    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    private var isPanning: Bool = false
    // track the previous scale to allow for incremental zooms in/out
    // with multiple sequential pinches
    private var prevScale: CGFloat = 0
    
    init(minScale: CGFloat,
         maxScale: CGFloat,
         scaleChange: @escaping (CGFloat) -> Void,
         anchorChange: @escaping (UnitPoint) -> Void,
         offsetChange: @escaping (CGSize) -> Void) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.scaleChange = scaleChange
        self.anchorChange = anchorChange
        self.offsetChange = offsetChange
        super.init(frame: .zero)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panView(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func panView(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPanning = true
            if gesture.numberOfTouches == 2 {
                let firstTouch = gesture.location(ofTouch: 0, in: self)
                let secondTouch = gesture.location(ofTouch: 1, in: self)
                let mid = CGPoint(x: (firstTouch.x + secondTouch.x)/2, y: (firstTouch.y + secondTouch.y)/2)
                startLocation = mid
            }
        case .changed:
            if gesture.numberOfTouches == 2 {
                let firstTouch = gesture.location(ofTouch: 0, in: self)
                let secondTouch = gesture.location(ofTouch: 1, in: self)
                let mid = CGPoint(x: (firstTouch.x + secondTouch.x)/2, y: (firstTouch.y + secondTouch.y)/2)
                location = mid
                offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            }
        case .possible, .cancelled, .failed:
            isPanning = false
            scale = 1.0
            anchor = .center
            offset = .zero
            
        case .ended:
            isPanning = false
        @unknown default:
            break
        }
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches
            prevScale = scale
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                numberOfTouches = gesture.numberOfTouches
            }
            scale = clamp(prevScale * gesture.scale, minScale, maxScale)
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
        case .possible, .cancelled, .failed:
            isPinching = false
            scale = 1.0
            anchor = .center
            offset = .zero
        case .ended:
            isPinching = false
        @unknown default:
            break
        }
    }
}

// Wraps ZoomableView and exposes it to SwiftUI
struct ZoomableOverlay: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    let minScale: CGFloat
    let maxScale: CGFloat
    
    let delegate = GestureRecognizerDelegate()

    func makeUIView(context: Context) -> some UIView {
//        let uiView = ZoomableView(minScale: minScale,
//                                  maxScale: maxScale,
//                                  scaleChange: { scale = $0 },
//                                  anchorChange: { anchor = $0 },
//                                  offsetChange: { offset = $0 })
        let uiView = UIView()
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panView(gesture:)))
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action:
                                                        #selector(Coordinator.pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        
        panGesture.delegate = self.delegate
        pinchGesture.delegate = self.delegate
        
        uiView.addGestureRecognizer(pinchGesture)
        uiView.addGestureRecognizer(panGesture)
        return uiView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scale: $scale, anchor: $anchor, offset: $offset, minScale: minScale, maxScale: maxScale)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @Binding var scale: CGFloat
        @Binding var anchor: UnitPoint
        @Binding var offset: CGSize
        let minScale: CGFloat
        let maxScale: CGFloat
        
        private var isPinching: Bool = false
        private var startLocation: CGPoint = .zero
        private var location: CGPoint = .zero
        private var numberOfTouches: Int = 0
        private var isPanning: Bool = false
        // track the previous scale to allow for incremental zooms in/out
        // with multiple sequential pinches
        private var prevScale: CGFloat = 0
        
        init(scale: Binding<CGFloat>, anchor: Binding<UnitPoint>, offset: Binding<CGSize>, minScale: CGFloat, maxScale: CGFloat) {
            self._scale = scale
            self._anchor = anchor
            self._offset = offset
            self.minScale = minScale
            self.maxScale = maxScale
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        @objc func panView(gesture: UIPanGestureRecognizer) {
    
            switch gesture.state {
            case .began:
                isPanning = true
                if gesture.numberOfTouches == 2 {
                    let firstTouch = gesture.location(ofTouch: 0, in: gesture.view)
                    let secondTouch = gesture.location(ofTouch: 1, in: gesture.view)
                    let mid = CGPoint(x: (firstTouch.x + secondTouch.x)/2, y: (firstTouch.y + secondTouch.y)/2)
                    startLocation = mid
                }
            case .changed:
                if gesture.numberOfTouches == 2 {
//                    let firstTouch = gesture.location(ofTouch: 0, in: gesture.view)
//                    let secondTouch = gesture.location(ofTouch: 1, in: gesture.view)
//                    let mid = CGPoint(x: (firstTouch.x + secondTouch.x)/2, y: (firstTouch.y + secondTouch.y)/2)
//                    location = mid
                    if gesture.view != nil {
                        let view = gesture.view
                        
                        let translation = gesture.translation(in: view?.superview)
//                        view?.center = CGPoint(x: (view?.center.x ?? 0.0) + translation.x, y: (view?.center.y ?? 0.0) + translation.y)
                        offset = CGSize(width: startLocation.x + translation.x, height: startLocation.y + translation.y)
                    }
                }
            case .possible, .cancelled, .failed:
                isPanning = false
                scale = 1.0
                anchor = .center
                offset = .zero
                
            case .ended:
                isPanning = false
                startLocation = .zero
            @unknown default:
                break
            }
        }
        
        @objc func pinch(gesture: UIPinchGestureRecognizer) {
            guard let view = gesture.view else {
                return
            }
            switch gesture.state {
            case .began:
                isPinching = true
                startLocation = gesture.location(in: gesture.view)
                anchor = UnitPoint(x: startLocation.x / view.bounds.width, y: startLocation.y / view.bounds.height)
                numberOfTouches = gesture.numberOfTouches
                prevScale = scale
            case .changed:
                if gesture.numberOfTouches != numberOfTouches {
                    let newLocation = gesture.location(in: gesture.view)
                    let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                    startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                    numberOfTouches = gesture.numberOfTouches
                }
                scale = clamp(prevScale * gesture.scale, minScale, maxScale)
                location = gesture.location(in: gesture.view)
                offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            case .possible, .cancelled, .failed:
                isPinching = false
                scale = 1.0
                anchor = .center
                offset = .zero
            case .ended:
                isPinching = false
            @unknown default:
                break
            }
        }
        
    }
    
    class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}

// Applies ZoomableOverlay to intercept gestures and apply scale,
// anchor point and offset
struct Zoomable: ViewModifier {
    @Binding var scale: CGFloat
    @State private var anchor: UnitPoint = .center
    @Binding var offset: CGSize
    let minScale: CGFloat
    let maxScale: CGFloat
    
    init(scale: Binding<CGFloat>,
         offset: Binding<CGSize>,
         minScale: CGFloat,
         maxScale: CGFloat) {
        _scale = scale
        _offset = offset
        self.minScale = minScale
        self.maxScale = maxScale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(.spring()) // looks more natural
            .overlay(ZoomableOverlay(scale: $scale,
                                     anchor: $anchor,
                                     offset: $offset,
                                     minScale: minScale,
                                     maxScale: maxScale))
            .gesture(TapGesture(count: 2).onEnded {
                if scale != 1 { // reset the scale
                    scale = clamp(1, minScale, maxScale)
                    anchor = .center
                    offset = .zero
                } else { // quick zoom
                    scale = clamp(2, minScale, maxScale)
                }
            })
    }
}

extension View {
    func zoomable(scale: Binding<CGFloat>,
                  offset: Binding<CGSize>,
                  minScale: CGFloat = 0.5,
                  maxScale: CGFloat = 9) -> some View {
        modifier(Zoomable(scale: scale, offset: offset, minScale: minScale, maxScale: maxScale))
    }
}
