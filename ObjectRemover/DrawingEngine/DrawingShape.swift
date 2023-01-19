//
//  DrawingShape.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 09/01/2023.
//

import SwiftUI

struct DrawingShape: Shape {
    
    let points: [CGPoint]
    let engine = DrawingEngine()
    func path(in rect: CGRect) -> Path {
        engine.createPath(for: points)
    }
    
}
