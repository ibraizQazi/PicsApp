//
//  EditorCanvasView.swift
//  ObjectRemover
//
//  Canvas view for drawing masks and displaying images.
//  Uses UnifiedGestureHandler for touch handling.
//

import SwiftUI

struct EditorCanvasView: View {
    let image: UIImage
    @ObservedObject var viewModel: EditorViewModel
    let selectedTool: EditorTool
    let brushSettings: BrushSettings

    @StateObject private var gestureHandler = UnifiedGestureHandler()

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
                .scaleEffect(gestureHandler.scale, anchor: gestureHandler.anchor)
                .offset(gestureHandler.offset)

                // Gesture overlay
                UnifiedGestureOverlay(handler: gestureHandler)

                // Clone source indicator (when in clone mode)
                if selectedTool == .cloneStamp, let sourcePoint = viewModel.cloneSourcePoint {
                    CloneSourceIndicator(
                        point: sourcePoint,
                        size: brushSettings.size,
                        scale: gestureHandler.scale,
                        offset: gestureHandler.offset
                    )
                }

                // Clone source preview in corner
                if selectedTool == .cloneStamp, viewModel.cloneSourcePoint != nil {
                    CloneSourcePreview(
                        sourcePoint: viewModel.cloneSourcePoint!,
                        image: viewModel.currentImage ?? image,
                        size: 80
                    )
                }
            }
            .background(Color.black)
            .clipped()
        }
        .onAppear {
            setupGestureCallbacks()
            updateGestureConfiguration()
        }
        .onChange(of: selectedTool) { _, newTool in
            updateGestureConfiguration()
        }
    }

    // MARK: - Gesture Setup

    private func setupGestureCallbacks() {
        gestureHandler.onDrawingBegan = { point in
            if selectedTool == .cloneStamp && viewModel.cloneSourcePoint == nil {
                // First, set the source point
                viewModel.setCloneSource(at: point)
            } else {
                viewModel.startStroke(at: point, settings: brushSettings)
            }
        }

        gestureHandler.onDrawingMoved = { point in
            viewModel.continueStroke(to: point)
        }

        gestureHandler.onDrawingEnded = {
            viewModel.endStroke()
        }

        gestureHandler.onTap = { point in
            if selectedTool == .cloneStamp {
                viewModel.setCloneSource(at: point)
            }
        }
    }

    private func updateGestureConfiguration() {
        gestureHandler.configuration.drawingEnabled = true
        gestureHandler.enableTapForCloneSource(selectedTool == .cloneStamp)
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
        ZStack {
            // Crosshair circle
            Circle()
                .stroke(Color.cyan, lineWidth: 2)
                .frame(width: size * scale, height: size * scale)
                .position(
                    x: point.x * scale + offset.width,
                    y: point.y * scale + offset.height
                )

            // Center cross
            Group {
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 2, height: 16)
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 16, height: 2)
            }
            .position(
                x: point.x * scale + offset.width,
                y: point.y * scale + offset.height
            )
        }
    }
}

// MARK: - Clone Source Preview

private struct CloneSourcePreview: View {
    let sourcePoint: CGPoint
    let image: UIImage
    let size: CGFloat

    var body: some View {
        VStack {
            HStack {
                Spacer()

                ZStack {
                    // Background
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: size + 8, height: size + 8)

                    // Sampled region preview
                    if let preview = extractPreview() {
                        Image(uiImage: preview)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: size, height: size)
                    }

                    // Border
                    Circle()
                        .stroke(Color.cyan, lineWidth: 2)
                        .frame(width: size, height: size)
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 16)

            Spacer()
        }
    }

    private func extractPreview() -> UIImage? {
        let sampleSize: CGFloat = 60
        let rect = CGRect(
            x: sourcePoint.x - sampleSize / 2,
            y: sourcePoint.y - sampleSize / 2,
            width: sampleSize,
            height: sampleSize
        )

        // Clamp to image bounds
        let clampedRect = rect.intersection(CGRect(origin: .zero, size: image.size))
        guard !clampedRect.isEmpty else { return nil }

        guard let cgImage = image.cgImage?.cropping(to: clampedRect) else { return nil }
        return UIImage(cgImage: cgImage)
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
