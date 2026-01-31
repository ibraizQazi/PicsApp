//
//  EditorCanvasView.swift
//  ObjectRemover
//
//  Canvas view for drawing masks and displaying images.
//  Integrates with UnifiedGestureHandler for touch handling.
//

import SwiftUI

struct EditorCanvasView: View {
    let image: UIImage
    @ObservedObject var viewModel: EditorViewModel
    let selectedTool: EditorTool
    let brushSettings: BrushSettings

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var anchor: UnitPoint = .center

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image with strokes overlay
                Canvas { context, size in
                    // Draw the current image
                    let imageSize = calculateImageSize(for: image.size, in: size)
                    let imageRect = CGRect(
                        x: (size.width - imageSize.width) / 2,
                        y: (size.height - imageSize.height) / 2,
                        width: imageSize.width,
                        height: imageSize.height
                    )

                    if let cgImage = (viewModel.currentImage ?? image).cgImage {
                        context.draw(Image(decorative: cgImage, scale: 1.0), in: imageRect)
                    }

                    // Draw strokes
                    for stroke in viewModel.strokes {
                        let path = createPath(for: stroke.points)
                        context.stroke(
                            path,
                            with: .color(Color(stroke.brushSettings.uiColor)),
                            style: StrokeStyle(
                                lineWidth: stroke.brushSettings.size,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }

                    // Draw current stroke being drawn
                    if !viewModel.currentPoints.isEmpty {
                        let path = createPath(for: viewModel.currentPoints)
                        context.stroke(
                            path,
                            with: .color(Color(brushSettings.uiColor)),
                            style: StrokeStyle(
                                lineWidth: brushSettings.size,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }
                }
                .scaleEffect(scale, anchor: anchor)
                .offset(offset)
                .gesture(drawGesture(in: geometry.size))
                .gesture(zoomGesture)
                .simultaneousGesture(panGesture)

                // Clone source indicator (when in clone mode)
                if selectedTool == .cloneStamp, let sourcePoint = viewModel.cloneSourcePoint {
                    CloneSourceIndicator(
                        point: sourcePoint,
                        size: brushSettings.size,
                        scale: scale,
                        offset: offset
                    )
                }
            }
            .background(Color.black)
            .clipped()
        }
    }

    // MARK: - Gestures

    private func drawGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Only draw with single finger (no modifier keys)
                let point = transformPoint(value.location, in: size)

                if selectedTool == .cloneStamp && viewModel.cloneSourcePoint == nil {
                    // In clone mode without source, this tap sets the source
                    return
                }

                if value.translation == .zero {
                    // New stroke started
                    viewModel.startStroke(at: point, settings: brushSettings)
                } else {
                    viewModel.continueStroke(to: point)
                }
            }
            .onEnded { _ in
                viewModel.endStroke()
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = max(0.5, min(8.0, value))
            }
            .onEnded { value in
                scale = max(0.5, min(8.0, value))
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                // Only pan with two fingers (simulated by checking if we're zoomed)
                guard scale > 1.0 else { return }
                offset = CGSize(
                    width: value.translation.width,
                    height: value.translation.height
                )
            }
            .onEnded { value in
                offset = CGSize(
                    width: value.translation.width,
                    height: value.translation.height
                )
            }
    }

    // MARK: - Helper Methods

    private func calculateImageSize(for originalSize: CGSize, in targetSize: CGSize) -> CGSize {
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio)

        return CGSize(
            width: originalSize.width * scaleFactor,
            height: originalSize.height * scaleFactor
        )
    }

    private func transformPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        // Transform screen point to image coordinates
        let centerX = size.width / 2
        let centerY = size.height / 2

        let offsetX = point.x - offset.width
        let offsetY = point.y - offset.height

        let scaledX = centerX + (offsetX - centerX) / scale
        let scaledY = centerY + (offsetY - centerY) / scale

        return CGPoint(x: scaledX, y: scaledY)
    }

    private func createPath(for points: [CGPoint]) -> Path {
        var path = Path()
        guard points.count > 1 else {
            if let point = points.first {
                path.move(to: point)
                path.addLine(to: point)
            }
            return path
        }

        path.move(to: points[0])

        for i in 1..<points.count {
            let mid = CGPoint(
                x: (points[i - 1].x + points[i].x) / 2,
                y: (points[i - 1].y + points[i].y) / 2
            )
            path.addQuadCurve(to: mid, control: points[i - 1])
        }

        if let last = points.last {
            path.addLine(to: last)
        }

        return path
    }
}

// MARK: - Clone Source Indicator

private struct CloneSourceIndicator: View {
    let point: CGPoint
    let size: CGFloat
    let scale: CGFloat
    let offset: CGSize

    var body: some View {
        Circle()
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: size, height: size)
            .position(x: point.x * scale + offset.width, y: point.y * scale + offset.height)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
                    .position(x: point.x * scale + offset.width, y: point.y * scale + offset.height)
            )
    }
}

// MARK: - Preview

#Preview {
    EditorCanvasView(
        image: UIImage(systemName: "photo")!,
        viewModel: EditorViewModel(),
        selectedTool: .brush,
        brushSettings: BrushSettings()
    )
}
