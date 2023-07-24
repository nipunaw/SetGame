//
//  Diamond.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/22/23.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Start at bottom of diamond
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)) // Right of diamond
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // Top of diamond
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY)) // Left of diamond
        p.addLine(to: CGPoint(x: rect.midX, y: rect.minY)) // Bottom of diamond
        return p
    }
    
    
    
}
