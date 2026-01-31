//
//  UnifiedGestureHandler.swift
//  ObjectRemover
//
//  Unified gesture handler for the editor canvas.
//  Combines drawing, zooming, panning, and clone source selection.
//
//  Gesture mapping:
//  - Single finger drag: Draw stroke / Paint clone
//  - Single finger tap: Select clone source (when in clone mode)
//  - Two finger drag: Pan viewport
//  - Two finger pinch: Zoom in/out
//  - Double tap: Reset zoom or quick zoom 2x
//

import UIKit
import SwiftUI
import Combine

// MARK: - Gesture State

struct EditorGestureState {
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var anchor: UnitPoint = .center
    var isDrawing: Bool = false
    var isZooming: Bool = false
    var isPanning: Bool = false
}

// MARK: - Unified Gesture Handler

final class UnifiedGestureHandler: NSObject, ObservableObject {

    // MARK: - Published State

    @Published private(set) var scale: CGFloat = 1.0
    @Published private(set) var offset: CGSize = .zero
    @Published private(set) var anchor: UnitPoint = .center
    @Published private(set) var isDrawing: Bool = false

    // MARK: - Callbacks

    var onDrawingBegan: ((CGPoint) -> Void)?
    var onDrawingMoved: ((CGPoint) -> Void)?
    var onDrawingEnded: (() -> Void)?
    var onTap: ((CGPoint) -> Void)?

    // MARK: - Configuration

    struct Configuration {
        var minScale: CGFloat = 0.5
        var maxScale: CGFloat = 8.0
        var drawingEnabled: Bool = true
        var tapEnabled: Bool = false  // For clone source selection
        var minimumDrawDistance: CGFloat = 3.0  // Prevents accidental draws
    }

    var configuration = Configuration()

    // MARK: - Private State

    private var accumulatedScale: CGFloat = 1.0
    private var accumulatedOffset: CGSize = .zero
    private var startPanLocation: CGPoint = .zero
    private var currentPinchScale: CGFloat = 1.0
    private var numberOfActiveTouches: Int = 0
    private var drawStartPoint: CGPoint?
    private var hasMovedEnoughToDraw: Bool = false

    // MARK: - Setup

    func setupGestures(on view: UIView) {
        // Remove any existing gestures
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }

        // Single finger draw gesture
        let drawPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawPan(_:)))
        drawPanGesture.minimumNumberOfTouches = 1
        drawPanGesture.maximumNumberOfTouches = 1
        drawPanGesture.delegate = self

        // Two finger pan gesture
        let viewportPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleViewportPan(_:)))
        viewportPanGesture.minimumNumberOfTouches = 2
        viewportPanGesture.maximumNumberOfTouches = 2
        viewportPanGesture.delegate = self

        // Pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self

        // Tap gesture (for clone source selection)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1

        // Double tap gesture (reset/quick zoom)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2

        // Single tap requires double tap to fail
        tapGesture.require(toFail: doubleTapGesture)
        // Draw gesture requires tap to fail to prevent initial touch from drawing
        drawPanGesture.require(toFail: tapGesture)

        view.addGestureRecognizer(drawPanGesture)
        view.addGestureRecognizer(viewportPanGesture)
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(doubleTapGesture)

        // Make view interactive
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
    }

    // MARK: - Drawing Gesture

    @objc private func handleDrawPan(_ gesture: UIPanGestureRecognizer) {
        guard configuration.drawingEnabled, let view = gesture.view else { return }

        let location = gesture.location(in: view)
        let transformedPoint = transformPoint(location, in: view)

        switch gesture.state {
        case .began:
            drawStartPoint = location
            hasMovedEnoughToDraw = false

        case .changed:
            // Check if we've moved enough to start drawing
            if !hasMovedEnoughToDraw {
                if let startPoint = drawStartPoint {
                    let distance = hypot(location.x - startPoint.x, location.y - startPoint.y)
                    if distance >= configuration.minimumDrawDistance {
                        hasMovedEnoughToDraw = true
                        isDrawing = true
                        // Start drawing from the start point
                        let startTransformed = transformPoint(startPoint, in: view)
                        onDrawingBegan?(startTransformed)
                    }
                }
            }

            if hasMovedEnoughToDraw {
                onDrawingMoved?(transformedPoint)
            }

        case .ended, .cancelled, .failed:
            if hasMovedEnoughToDraw {
                isDrawing = false
                onDrawingEnded?()
            }
            drawStartPoint = nil
            hasMovedEnoughToDraw = false

        default:
            break
        }
    }

    // MARK: - Viewport Pan Gesture

    @objc private func handleViewportPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            if gesture.numberOfTouches == 2 {
                let touch1 = gesture.location(ofTouch: 0, in: view)
                let touch2 = gesture.location(ofTouch: 1, in: view)
                startPanLocation = CGPoint(
                    x: (touch1.x + touch2.x) / 2,
                    y: (touch1.y + touch2.y) / 2
                )
            }

        case .changed:
            let translation = gesture.translation(in: view)
            offset = CGSize(
                width: accumulatedOffset.width + translation.x,
                height: accumulatedOffset.height + translation.y
            )

        case .ended:
            accumulatedOffset = offset

        case .cancelled, .failed:
            offset = accumulatedOffset

        default:
            break
        }
    }

    // MARK: - Pinch Gesture

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            let location = gesture.location(in: view)
            anchor = UnitPoint(
                x: location.x / view.bounds.width,
                y: location.y / view.bounds.height
            )
            currentPinchScale = gesture.scale

        case .changed:
            let newScale = accumulatedScale * gesture.scale
            scale = clamp(newScale, configuration.minScale, configuration.maxScale)

        case .ended:
            accumulatedScale = scale

        case .cancelled, .failed:
            scale = accumulatedScale

        default:
            break
        }
    }

    // MARK: - Tap Gesture

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard configuration.tapEnabled, let view = gesture.view else { return }

        let location = gesture.location(in: view)
        let transformedPoint = transformPoint(location, in: view)
        onTap?(transformedPoint)
    }

    // MARK: - Double Tap Gesture

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scale != 1.0 {
            // Reset to default
            resetViewport(animated: true)
        } else {
            // Quick zoom to 2x
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = clamp(2.0, configuration.minScale, configuration.maxScale)
                accumulatedScale = scale
            }
        }
    }

    // MARK: - Helper Methods

    /// Transform a screen point to image coordinates accounting for scale and offset
    private func transformPoint(_ point: CGPoint, in view: UIView) -> CGPoint {
        let centerX = view.bounds.width / 2
        let centerY = view.bounds.height / 2

        // Remove offset
        let offsetX = point.x - offset.width
        let offsetY = point.y - offset.height

        // Remove scale (transform from screen to content coordinates)
        let anchorX = anchor.x * view.bounds.width
        let anchorY = anchor.y * view.bounds.height

        let scaledX = anchorX + (offsetX - anchorX) / scale
        let scaledY = anchorY + (offsetY - anchorY) / scale

        return CGPoint(x: scaledX, y: scaledY)
    }

    /// Reset viewport to default state
    func resetViewport(animated: Bool) {
        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                offset = .zero
                anchor = .center
            }
        } else {
            scale = 1.0
            offset = .zero
            anchor = .center
        }
        accumulatedScale = 1.0
        accumulatedOffset = .zero
    }

    /// Clamp a value between min and max
    private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        min(maxValue, max(minValue, value))
    }

    // MARK: - Public Methods

    /// Enable tap gestures for clone source selection
    func enableTapForCloneSource(_ enabled: Bool) {
        configuration.tapEnabled = enabled
    }

    /// Enable or disable drawing
    func setDrawingEnabled(_ enabled: Bool) {
        configuration.drawingEnabled = enabled
    }

    /// Get current gesture state
    func getState() -> EditorGestureState {
        EditorGestureState(
            scale: scale,
            offset: offset,
            anchor: anchor,
            isDrawing: isDrawing,
            isZooming: false,
            isPanning: false
        )
    }
}

// MARK: - UIGestureRecognizerDelegate

extension UnifiedGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow pinch and two-finger pan to work together
        if gestureRecognizer is UIPinchGestureRecognizer &&
           otherGestureRecognizer is UIPanGestureRecognizer {
            if let pan = otherGestureRecognizer as? UIPanGestureRecognizer {
                return pan.minimumNumberOfTouches == 2
            }
        }

        if gestureRecognizer is UIPanGestureRecognizer &&
           otherGestureRecognizer is UIPinchGestureRecognizer {
            if let pan = gestureRecognizer as? UIPanGestureRecognizer {
                return pan.minimumNumberOfTouches == 2
            }
        }

        return false
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Single finger pan should not interfere with two-finger gestures
        if gestureRecognizer is UIPanGestureRecognizer,
           let pan = gestureRecognizer as? UIPanGestureRecognizer,
           pan.maximumNumberOfTouches == 1 {
            if otherGestureRecognizer is UIPinchGestureRecognizer {
                return true
            }
        }
        return false
    }
}

// MARK: - SwiftUI Wrapper

struct UnifiedGestureOverlay: UIViewRepresentable {
    @ObservedObject var handler: UnifiedGestureHandler

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        handler.setupGestures(on: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - View Modifier

struct UnifiedGestureModifier: ViewModifier {
    @ObservedObject var handler: UnifiedGestureHandler

    func body(content: Content) -> some View {
        content
            .scaleEffect(handler.scale, anchor: handler.anchor)
            .offset(handler.offset)
            .overlay(
                UnifiedGestureOverlay(handler: handler)
            )
    }
}

extension View {
    func unifiedGestures(handler: UnifiedGestureHandler) -> some View {
        modifier(UnifiedGestureModifier(handler: handler))
    }
}
