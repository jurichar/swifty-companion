//
//  RadarView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 13/08/2023.
//

import Foundation
import SwiftUI

struct RadarView: View {
    var skills: [Skill]
    var maxLevel: Double = 20.0
    let interval: Double = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) * 0.4
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let levelsToDraw: [Int] = Array(stride(from: Int(interval), to: Int(maxLevel) + 1, by: Int(interval)))
            
            // Drawing the spider web
            ForEach(levelsToDraw, id: \.self) { levelMultiplier in
                let currentRadius = CGFloat(Double(levelMultiplier) / self.maxLevel) * radius
                ZStack {
                    PolygonShape(sides: self.skills.count, radius: currentRadius)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                }
            }
            
            // Drawing the skill levels
            RadarShape(levels: self.skills.map { $0.level / self.maxLevel }, radius: radius)
                .fill(Color.blue.opacity(0.3))
                .overlay(RadarShape(levels: self.skills.map { $0.level / self.maxLevel }, radius: radius).stroke(Color.blue, lineWidth: 2))
            
            // Add names
            ForEach(self.skills) { skill in
                let index = self.skills.firstIndex(where: { $0.id == skill.id })!
                let angle = 2 * .pi / Double(self.skills.count) * Double(index)
                let position = CGPoint(x: center.x + radius * 1.1 * CGFloat(cos(angle)), y: center.y + radius * 1.1 * CGFloat(sin(angle)))
                Text(skill.name)
                    .frame(maxWidth: 70, alignment: .center)
                    .position(position)
                    .font(.system(size: 7, design: .monospaced))
            }
        }
    }
}

struct PolygonShape: Shape {
    var sides: Int
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var path = Path()
        for i in 0..<sides {
            let angle = 2 * .pi / CGFloat(sides) * CGFloat(i)
            let position = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 {
                path.move(to: position)
            } else {
                path.addLine(to: position)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarShape: Shape {
    var levels: [Double]
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var path = Path()
        for i in 0..<levels.count {
            let angle = 2 * .pi / CGFloat(levels.count) * CGFloat(i)
            let currentRadius = CGFloat(levels[i]) * radius
            let position = CGPoint(x: center.x + currentRadius * cos(angle), y: center.y + currentRadius * sin(angle))
            if i == 0 {
                path.move(to: position)
            } else {
                path.addLine(to: position)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Skill : Identifiable{
    var id = UUID()
    var name: String
    var level: Double
}

