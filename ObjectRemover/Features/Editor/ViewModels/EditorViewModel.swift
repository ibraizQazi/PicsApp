//
//  EditorViewModel.swift
//  ObjectRemover
//
//  ViewModel for the editor view managing strokes, undo/redo, and image state.
//

import SwiftUI
import Combine

@MainActor
class EditorViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var originalImage: UIImage?
    @Published private(set) var currentImage: UIImage?
    @Published private(set) var strokes: [Stroke] = []
    @Published private(set) var currentPoints: [CGPoint] = []
    @Published private(set) var cloneSourcePoint: CGPoint?

    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false

    // MARK: - Private State

    private var undoStack: [UndoableAction] = []
    private var redoStack: [UndoableAction] = []
    private var currentBrushSettings: BrushSettings = BrushSettings()

    // MARK: - Initialization

    init() {}

    // MARK: - Image Management

    func setOriginalImage(_ image: UIImage) {
        originalImage = image
        currentImage = image
        strokes = []
        undoStack = []
        redoStack = []
        updateUndoRedoState()
    }

    func applyRemovalResult(_ result: UIImage) {
        guard let currentImage = currentImage else { return }

        // Record as undoable action
        let action = RemovalUndoAction(
            beforeImage: currentImage,
            afterImage: result,
            strokes: strokes
        )
        recordAction(action)

        self.currentImage = result
        strokes = []
    }

    // MARK: - Stroke Management

    func startStroke(at point: CGPoint, settings: BrushSettings) {
        currentPoints = [point]
        currentBrushSettings = settings
    }

    func continueStroke(to point: CGPoint) {
        currentPoints.append(point)
    }

    func endStroke() {
        guard !currentPoints.isEmpty else { return }

        let stroke = Stroke(points: currentPoints, brushSettings: currentBrushSettings)
        let action = StrokeUndoAction(stroke: stroke)
        recordAction(action)

        strokes.append(stroke)
        currentPoints = []
    }

    // MARK: - Clone Stamp

    func setCloneSource(at point: CGPoint) {
        cloneSourcePoint = point
    }

    func clearCloneSource() {
        cloneSourcePoint = nil
    }

    // MARK: - Mask Generation

    func generateMask(for size: CGSize) -> UIImage? {
        guard !strokes.isEmpty else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Fill with black (areas to keep)
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            // Draw strokes in white (areas to remove)
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)

            for stroke in strokes {
                context.cgContext.setLineWidth(stroke.brushSettings.size)

                guard stroke.points.count > 1 else {
                    if let point = stroke.points.first {
                        context.cgContext.move(to: point)
                        context.cgContext.addLine(to: point)
                        context.cgContext.strokePath()
                    }
                    continue
                }

                context.cgContext.move(to: stroke.points[0])

                for i in 1..<stroke.points.count {
                    let mid = CGPoint(
                        x: (stroke.points[i - 1].x + stroke.points[i].x) / 2,
                        y: (stroke.points[i - 1].y + stroke.points[i].y) / 2
                    )
                    context.cgContext.addQuadCurve(to: mid, control: stroke.points[i - 1])
                }

                if let last = stroke.points.last {
                    context.cgContext.addLine(to: last)
                }

                context.cgContext.strokePath()
            }
        }
    }

    // MARK: - Undo/Redo

    func undo() {
        guard let action = undoStack.popLast() else { return }

        action.undo(on: self)
        redoStack.append(action)
        updateUndoRedoState()
    }

    func redo() {
        guard let action = redoStack.popLast() else { return }

        action.redo(on: self)
        undoStack.append(action)
        updateUndoRedoState()
    }

    private func recordAction(_ action: UndoableAction) {
        undoStack.append(action)
        redoStack.removeAll()
        updateUndoRedoState()
    }

    private func updateUndoRedoState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }

    // MARK: - Internal Mutation (for undo/redo actions)

    func restoreStrokes(_ newStrokes: [Stroke]) {
        strokes = newStrokes
    }

    func restoreImage(_ image: UIImage) {
        currentImage = image
    }
}

// MARK: - Undoable Actions

@MainActor
private protocol UndoableAction {
    func undo(on viewModel: EditorViewModel)
    func redo(on viewModel: EditorViewModel)
}

private struct StrokeUndoAction: UndoableAction {
    let stroke: Stroke

    @MainActor
    func undo(on viewModel: EditorViewModel) {
        var strokes = viewModel.strokes
        if let index = strokes.firstIndex(where: { $0.id == stroke.id }) {
            strokes.remove(at: index)
            viewModel.restoreStrokes(strokes)
        }
    }

    @MainActor
    func redo(on viewModel: EditorViewModel) {
        var strokes = viewModel.strokes
        strokes.append(stroke)
        viewModel.restoreStrokes(strokes)
    }
}

private struct RemovalUndoAction: UndoableAction {
    let beforeImage: UIImage
    let afterImage: UIImage
    let strokes: [Stroke]

    @MainActor
    func undo(on viewModel: EditorViewModel) {
        viewModel.restoreImage(beforeImage)
        viewModel.restoreStrokes(strokes)
    }

    @MainActor
    func redo(on viewModel: EditorViewModel) {
        viewModel.restoreImage(afterImage)
        viewModel.restoreStrokes([])
    }
}
