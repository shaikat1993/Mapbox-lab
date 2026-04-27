//
//  MarkerImageRenderer.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit

enum MarkerImageRenderer {
    static func image(for shape: MarkerShape,
                      color: MarkerColor) -> UIImage {
        let size = CGSize(width: 44, height: 44)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            color.uiColor.setFill()
            switch shape {
            case .pin:
                if let pin = UIImage(named: "pin") {
                    pin.withTintColor(color.uiColor,
                                      renderingMode: .alwaysOriginal).draw(in: rect)
                } else {
                    drawPin(in: ctx.cgContext, rect: rect, color: color.uiColor)
                }
            case .circle:
                UIBezierPath(ovalIn: rect.insetBy(dx: 4, dy: 4)).fill()
            case .dot:
                UIBezierPath(ovalIn: rect.insetBy(dx: 12, dy: 12)).fill()
            case .star:
                drawStar(in: ctx.cgContext, rect: rect, color: color.uiColor)
            }
        }
    }

    private static func drawPin(in context: CGContext, rect: CGRect, color: UIColor) {
        let cx = rect.midX
        let r: CGFloat = rect.width * 0.32       // circle radius
        let cy = rect.minY + r + 4               // circle center y (near top)
        let tipY = rect.maxY - 4                 // tip of the pin at bottom

        let path = UIBezierPath()
        // Left tangent from circle down to tip
        let angle = CGFloat.pi / 6              // 30° — controls how wide the pin is
        let leftX  = cx - r * sin(angle)
        let leftY  = cy + r * cos(angle)
        let rightX = cx + r * sin(angle)
        let rightY = cy + r * cos(angle)

        path.move(to: CGPoint(x: leftX, y: leftY))
        path.addLine(to: CGPoint(x: cx, y: tipY))
        path.addLine(to: CGPoint(x: rightX, y: rightY))
        // Arc across the top of the circle
        path.addArc(withCenter: CGPoint(x: cx, y: cy),
                    radius: r,
                    startAngle: .pi / 2 + angle,
                    endAngle: .pi / 2 - angle + .pi * 2,
                    clockwise: false)
        path.close()
        color.setFill()
        path.fill()

        // White inner dot
        let dotR: CGFloat = r * 0.38
        UIColor.white.withAlphaComponent(0.85).setFill()
        UIBezierPath(ovalIn: CGRect(x: cx - dotR, y: cy - dotR,
                                    width: dotR * 2, height: dotR * 2)).fill()
    }

    private static func drawStar(in context: CGContext,
                                 rect: CGRect,
                                 color: UIColor) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius: CGFloat = rect.width / 2 - 4
        let innerRadius: CGFloat = outerRadius * 0.4
        let points = 5
        var path = UIBezierPath()
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(x: center.x + radius * cos(angle),
                                y: center.y + radius * sin(angle))
            i == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.close()
        color.setFill()
        path.fill()
    }
}
