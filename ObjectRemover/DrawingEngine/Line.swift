//
//  Line.swift
//  ObjectRemover
//
//  Created by Ibraiz Qazi on 09/01/2023.
//

import Foundation
import SwiftUI

struct Line: Identifiable {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    let id = UUID()
}
