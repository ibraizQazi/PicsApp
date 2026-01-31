//
//  UndoableActionProtocol.swift
//  ObjectRemover
//
//  Protocol for actions that can be undone/redone in the editor.
//

import UIKit

// MARK: - Action Type

enum EditorActionType: String, Codable {
    case stroke
    case objectRemoval
    case clonePaint
    case filter
    case adjustment
}

// MARK: - Protocol

protocol UndoableActionProtocol {
    /// Unique identifier for this action
    var id: UUID { get }

    /// Human-readable name for the action (shown in UI)
    var actionName: String { get }

    /// Type of action
    var actionType: EditorActionType { get }

    /// When the action was performed
    var timestamp: Date { get }

    /// Estimated memory cost in bytes (for undo stack management)
    var memoryCost: Int { get }

    /// Execute the action on the editor state
    func execute(on state: inout EditorImageState) throws

    /// Undo the action on the editor state
    func undo(on state: inout EditorImageState) throws
}

// MARK: - Editor State

/// Represents the current state of the editor that actions can modify
struct EditorImageState {
    /// The current working image
    var currentImage: UIImage

    /// The original unmodified image
    let originalImage: UIImage

    /// Current strokes drawn on the image
    var strokes: [Stroke]

    /// Current brush settings
    var brushSettings: BrushSettings

    /// Selected tool
    var selectedTool: EditorTool

    /// Clone stamp source point (if applicable)
    var cloneSourcePoint: CGPoint?

    init(originalImage: UIImage) {
        self.originalImage = originalImage
        self.currentImage = originalImage
        self.strokes = []
        self.brushSettings = BrushSettings()
        self.selectedTool = .brush
        self.cloneSourcePoint = nil
    }
}

// MARK: - Stroke Model

struct Stroke: Identifiable, Codable {
    let id: UUID
    let points: [CGPoint]
    let brushSettings: BrushSettings
    let timestamp: Date

    init(points: [CGPoint], brushSettings: BrushSettings) {
        self.id = UUID()
        self.points = points
        self.brushSettings = brushSettings
        self.timestamp = Date()
    }
}

// MARK: - Brush Settings

struct BrushSettings: Codable, Equatable {
    var size: CGFloat
    var hardness: CGFloat
    var opacity: CGFloat
    var color: CodableColor

    init(
        size: CGFloat = 30,
        hardness: CGFloat = 0.8,
        opacity: CGFloat = 1.0,
        color: CodableColor = CodableColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    ) {
        self.size = size
        self.hardness = hardness
        self.opacity = opacity
        self.color = color
    }

    var uiColor: UIColor {
        UIColor(
            red: color.red,
            green: color.green,
            blue: color.blue,
            alpha: color.alpha
        )
    }
}

struct CodableColor: Codable, Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(uiColor: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
}

// MARK: - Editor Tool

enum EditorTool: String, CaseIterable, Identifiable {
    case brush = "Brush"
    case eraser = "Eraser"
    case cloneStamp = "Clone Stamp"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .brush: return "paintbrush.fill"
        case .eraser: return "eraser.fill"
        case .cloneStamp: return "stamp.fill"
        }
    }
}

// MARK: - CGPoint Codable Extension

extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}
