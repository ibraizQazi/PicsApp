//
//  CloneStampTool.swift
//  ObjectRemover
//
//  Clone stamp tool that samples pixels from a source region
//  and paints them at the destination.
//

import UIKit
import CoreGraphics

final class CloneStampTool {

    // MARK: - Configuration

    struct Configuration {
        var brushSize: CGFloat = 30
        var brushHardness: CGFloat = 0.8
        var opacity: CGFloat = 1.0
        var spacing: CGFloat = 0.15  // Spacing as fraction of brush size
    }

    var configuration = Configuration()

    // MARK: - State

    private var sourcePoint: CGPoint?
    private var lastPaintPoint: CGPoint?
    private var sourceImage: UIImage?
    private var offset: CGPoint = .zero

    // MARK: - Initialization

    init() {}

    // MARK: - Source Management

    /// Set the source point for cloning
    func setSource(point: CGPoint, in image: UIImage) {
        sourcePoint = point
        sourceImage = image
        lastPaintPoint = nil
        offset = .zero
    }

    /// Check if source is set
    var hasSource: Bool {
        sourcePoint != nil && sourceImage != nil
    }

    /// Get the current source point
    var currentSourcePoint: CGPoint? {
        sourcePoint
    }

    /// Reset the tool state
    func reset() {
        sourcePoint = nil
        lastPaintPoint = nil
        sourceImage = nil
        offset = .zero
    }

    // MARK: - Painting

    /// Start a new paint stroke
    func beginPaint(at point: CGPoint) {
        guard let sourcePoint = sourcePoint else { return }

        // Calculate offset from source to destination
        offset = CGPoint(
            x: point.x - sourcePoint.x,
            y: point.y - sourcePoint.y
        )
        lastPaintPoint = point
    }

    /// Paint at a destination point
    func paint(at destinationPoint: CGPoint, on targetImage: UIImage) -> UIImage? {
        guard let sourcePoint = sourcePoint,
              let sourceImage = sourceImage else {
            return nil
        }

        // If this is the first point, set initial offset
        if lastPaintPoint == nil {
            offset = CGPoint(
                x: destinationPoint.x - sourcePoint.x,
                y: destinationPoint.y - sourcePoint.y
            )
        }

        // Get points to paint along the stroke
        let pointsToPaint = interpolatePoints(
            from: lastPaintPoint ?? destinationPoint,
            to: destinationPoint
        )

        guard !pointsToPaint.isEmpty else { return targetImage }

        // Create new image with painted pixels
        let renderer = UIGraphicsImageRenderer(size: targetImage.size)

        let result = renderer.image { context in
            // Draw the existing target image
            targetImage.draw(at: .zero)

            // Set up clipping and blending
            context.cgContext.setAlpha(configuration.opacity)
            context.cgContext.setBlendMode(.normal)

            for point in pointsToPaint {
                // Calculate the corresponding source point
                let samplePoint = CGPoint(
                    x: point.x - offset.x,
                    y: point.y - offset.y
                )

                // Extract and paint the sampled region
                if let sampledRegion = extractCircularRegion(
                    from: sourceImage,
                    center: samplePoint,
                    radius: configuration.brushSize / 2
                ) {
                    let destRect = CGRect(
                        x: point.x - configuration.brushSize / 2,
                        y: point.y - configuration.brushSize / 2,
                        width: configuration.brushSize,
                        height: configuration.brushSize
                    )

                    // Create brush mask
                    context.cgContext.saveGState()
                    context.cgContext.addEllipse(in: destRect)
                    context.cgContext.clip()

                    // Draw the sampled region
                    sampledRegion.draw(in: destRect)

                    context.cgContext.restoreGState()
                }
            }
        }

        lastPaintPoint = destinationPoint
        return result
    }

    /// End the current paint stroke
    func endPaint() {
        lastPaintPoint = nil
    }

    // MARK: - Preview

    /// Generate a circular preview of the source region
    func generateSourcePreview(size: CGFloat) -> UIImage? {
        guard let sourcePoint = sourcePoint,
              let sourceImage = sourceImage else {
            return nil
        }
        return extractCircularRegion(from: sourceImage, center: sourcePoint, radius: size / 2)
    }

    // MARK: - Private Methods

    /// Interpolate points between two locations for smooth painting
    private func interpolatePoints(from: CGPoint, to: CGPoint) -> [CGPoint] {
        let distance = hypot(to.x - from.x, to.y - from.y)
        let spacing = configuration.brushSize * configuration.spacing

        guard distance > spacing else { return [to] }

        let steps = Int(distance / spacing)
        guard steps > 0 else { return [to] }

        return (0...steps).map { i in
            let t = CGFloat(i) / CGFloat(steps)
            return CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
        }
    }

    /// Extract a circular region from an image
    private func extractCircularRegion(
        from image: UIImage,
        center: CGPoint,
        radius: CGFloat
    ) -> UIImage? {
        let diameter = radius * 2
        let imageRect = CGRect(origin: .zero, size: image.size)

        // Check if center is within bounds
        guard center.x >= 0 && center.x <= image.size.width &&
              center.y >= 0 && center.y <= image.size.height else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))

        return renderer.image { context in
            // Create circular clip path
            context.cgContext.addEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            context.cgContext.clip()

            // Draw the portion of the image
            let drawRect = CGRect(
                x: radius - center.x,
                y: radius - center.y,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: drawRect)
        }
    }
}

// MARK: - Brush Hardness Extension

extension CloneStampTool {
    /// Create a brush mask with the specified hardness
    /// Hardness of 1.0 = hard edge, 0.0 = soft feathered edge
    func createBrushMask(size: CGFloat, hardness: CGFloat) -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2

            // Create gradient for soft brush
            if hardness < 1.0 {
                let colors = [
                    UIColor.white.cgColor,
                    UIColor.white.withAlphaComponent(1.0 - (1.0 - hardness) * 0.7).cgColor,
                    UIColor.white.withAlphaComponent(0).cgColor
                ]
                let locations: [CGFloat] = [0, hardness, 1]

                if let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors as CFArray,
                    locations: locations
                ) {
                    context.cgContext.drawRadialGradient(
                        gradient,
                        startCenter: center,
                        startRadius: 0,
                        endCenter: center,
                        endRadius: radius,
                        options: []
                    )
                }
            } else {
                // Hard brush
                context.cgContext.setFillColor(UIColor.white.cgColor)
                context.cgContext.fillEllipse(in: rect)
            }
        }

        return image.cgImage
    }
}
