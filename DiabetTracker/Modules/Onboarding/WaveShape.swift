//
//  WaveShape.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//

import Foundation
import SwiftUI

struct WaveHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.85)) // до начала изгиба
        
        // Создаем плавную волну
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height * 0.85),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        
        path.closeSubpath()
        return path
    }
}
