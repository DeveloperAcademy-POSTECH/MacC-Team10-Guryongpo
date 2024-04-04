//
//  RadarChartShape.swift
//  SoccerBeat
//
//  Created by Gucci on 4/4/24.
//

import SwiftUI

struct RadarChartShape: Shape {
    var dataPoints: [Double]
    var maxValue: Double
    
    // 데이터 포인트를 극좌표계로 변환
    private func pointForDataPoint(index: Int, in rect: CGRect) -> CGPoint {
        let angle = 2 * .pi / Double(dataPoints.count) * Double(index)
        let radius = (dataPoints[index] / maxValue) * min(rect.width, rect.height) / 2
        return CGPoint(
            x: rect.midX + cos(angle) * radius,
            y: rect.midY + sin(angle) * radius
        )
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let points = dataPoints.indices.map {
            pointForDataPoint(index: $0, in: rect)
        }
        
        guard let firstPoint = points.first else { return path }
        
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
}

struct RadarChartView: View {
    let averageDataPoints: [Double]
    let maximumDataPoints: [Double]
    
    let limitValue: Double
    
    var body: some View {
        ZStack {
            // MARK: - max line border
//            ForEach(0..<averageDataPoints.count) { index in
//                RadarChartShape(dataPoints: Array(repeating: limitValue, count: averageDataPoints.count), maxValue: limitValue)
//                    .stroke(Color.gray, lineWidth: 0.5)
//            }
            
            // MARK: - 평균 데이터 레이어
            RadarChartShape(dataPoints: averageDataPoints, maxValue: limitValue)
                .fill(Color.blue.opacity(0.3))
                .overlay(
                    RadarChartShape(dataPoints: averageDataPoints, maxValue: limitValue)
                        .stroke(Color.blue, lineWidth: 2)
                )
            
            // MARK: - 최고 데이터 레이어
            RadarChartShape(dataPoints: maximumDataPoints, maxValue: limitValue)
                .fill(Color.red.opacity(0.3))
                .overlay(
                    RadarChartShape(dataPoints: maximumDataPoints, maxValue: limitValue)
                        .stroke(Color.red, lineWidth: 2)
                )
        }
//        .frame(width: 300, height: 300)
    }
}

#Preview {
    let averageDataPoints = [0.7, 0.6, 0.8, 0.9, 1.0, 0.6]
    let currentDataPoints = [1.0, 0.3, 0.4, 0.7, 0.4, 0.3]
    let maxValue = 1.0
    
    return RadarChartView(averageDataPoints: averageDataPoints, maximumDataPoints: currentDataPoints, limitValue: maxValue)
}
