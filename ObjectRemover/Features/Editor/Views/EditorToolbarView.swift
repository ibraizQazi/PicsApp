//
//  EditorToolbarView.swift
//  ObjectRemover
//
//  Toolbar for editor with tool selection, brush settings, and action buttons.
//

import SwiftUI

struct EditorToolbarView: View {
    let selectedTool: EditorTool
    let brushSize: CGFloat
    let onToolSelected: (EditorTool) -> Void
    let onBrushSizeChanged: (CGFloat) -> Void
    let onUndoTapped: () -> Void
    let onRedoTapped: () -> Void
    let onCompareTapped: () -> Void
    let onRemoveTapped: () -> Void
    let canUndo: Bool
    let canRedo: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Brush size slider
            brushSizeSlider

            Divider()
                .background(Color.gray.opacity(0.3))

            // Tool buttons
            HStack(spacing: 0) {
                // Tool selection
                toolButtons

                Spacer()

                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
    }

    // MARK: - Brush Size Slider

    private var brushSizeSlider: some View {
        HStack(spacing: 16) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(.gray)

            Slider(value: Binding(
                get: { brushSize },
                set: { onBrushSizeChanged($0) }
            ), in: 10...100)
            .accentColor(.blue)

            Image(systemName: "circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)

            Text("\(Int(brushSize))")
                .font(.custom("Gilroy-Medium", size: 12))
                .foregroundColor(.gray)
                .frame(width: 30)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Tool Buttons

    private var toolButtons: some View {
        HStack(spacing: 16) {
            ForEach(EditorTool.allCases) { tool in
                ToolButton(
                    tool: tool,
                    isSelected: selectedTool == tool,
                    onTap: { onToolSelected(tool) }
                )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Undo
            Button(action: onUndoTapped) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 20))
                    .foregroundColor(canUndo ? .blue : .gray.opacity(0.5))
            }
            .disabled(!canUndo)

            // Redo
            Button(action: onRedoTapped) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 20))
                    .foregroundColor(canRedo ? .blue : .gray.opacity(0.5))
            }
            .disabled(!canRedo)

            // Compare
            Button(action: onCompareTapped) {
                Image(systemName: "square.on.square")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }

            // Remove button
            Button(action: onRemoveTapped) {
                Text("Remove")
                    .font(.custom("Gilroy-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
    }
}

// MARK: - Tool Button

private struct ToolButton: View {
    let tool: EditorTool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(tool.rawValue)
                    .font(.custom("Gilroy-Medium", size: 10))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#Preview {
    EditorToolbarView(
        selectedTool: .brush,
        brushSize: 30,
        onToolSelected: { _ in },
        onBrushSizeChanged: { _ in },
        onUndoTapped: {},
        onRedoTapped: {},
        onCompareTapped: {},
        onRemoveTapped: {},
        canUndo: true,
        canRedo: false
    )
}
