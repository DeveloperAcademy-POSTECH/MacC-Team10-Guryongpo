//
//  HeatmapView.swift
//  SoccerBeat
//
//  Created by daaan on 10/31/23.
//
//  HeatmapView.swift v2.0
//  Created by Hyungmin on 11/06/24.

import SwiftUI
import MapKit

// To attatch heatmap
// call HeatmapView with coordinate, polylineCoordinates
// HeatmapView(coordinate: CLLocationCoordinate2D(latitude, longitude),
// polylineCoordinates: [CLLocationCoordinate2D(latitude, longitude)])

struct HeatmapView: UIViewRepresentable {
    let centerCoordinate: CLLocationCoordinate2D
    let routes: [CLLocationCoordinate2D]
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        
        let overlays = createHeatmapOverlays(center: centerCoordinate, gridSize: 30, squareSize: 50)
                
        mapView.addOverlays(overlays)
                    
        return mapView
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HeatmapView
        
        init(_ parent: HeatmapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let rectangleOverlay = overlay as? FixedSizeRectangleOverlay {
                
                let shrinkFactor: Double = 0.8
                let shrunkenPoints = rectangleOverlay.points.map { point -> MKMapPoint in
                    let centerX = rectangleOverlay.boundingMapRect.midX
                    let centerY = rectangleOverlay.boundingMapRect.midY
                    let newX = centerX + (point.x - centerX) * shrinkFactor
                    let newY = centerY + (point.y - centerY) * shrinkFactor
                    return MKMapPoint(x: newX, y: newY)
                }
                
                let renderer = MKPolygonRenderer(polygon: MKPolygon(points: shrunkenPoints, count: shrunkenPoints.count))
                
                renderer.fillColor = rectangleOverlay.color
                
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
    
    func createHeatmapOverlays(center: CLLocationCoordinate2D, gridSize: Int, squareSize: Double) -> [FixedSizeRectangleOverlay] {
        var overlays: [FixedSizeRectangleOverlay] = []
        
        let centerMapPoint = MKMapPoint(center)
        
        let halfGrid = Double(gridSize) / 2.0
        
        let initialx = centerMapPoint.x - (squareSize * halfGrid)
        let initialy = centerMapPoint.y - (squareSize * halfGrid)
        
        var gridCount: [[Int]] = Array(repeating: Array(repeating: 0, count: gridSize+1), count: gridSize+1)
        
        for routePoint in routes {
            let mapPoint = MKMapPoint(routePoint)
            
            let col = Int((mapPoint.x - initialx) / squareSize)
            let row = Int((mapPoint.y - initialy) / squareSize)
            
            if row >= 0 && row < gridSize && col >= 0 && col < gridSize {
                gridCount[row][col] += 1
            }
        }
        
        let totalRouteCount = routes.count
        
        for row in 0..<gridSize+1 {
            for col in 0..<gridSize+1 {
                
                let mapPointx = initialx + (squareSize * Double(col))
                let mapPointy = initialy + (squareSize * Double(row))
                
                let mapPoint = MKMapPoint(x: mapPointx, y: mapPointy)
                let coordinate = mapPoint.coordinate
                
                let squareCenter = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                let ratio = Double(gridCount[row][col]) / Double(totalRouteCount)
                
                let color = colorForRatio(ratio)
                
                let overlay = FixedSizeRectangleOverlay(center: squareCenter, width: squareSize, height: squareSize, count: gridCount[row][col], color: color)
                
                overlays.append(overlay)
            }
        }
        return overlays
    }
    
    func colorForRatio(_ ratio: Double) -> UIColor {
        
        
        switch ratio {
        case 0...0.1:
            return UIColor.clear
        case 0.1...0.2:
            return UIColor(Color.heatmap90)
        case 0.2...0.3:
            return UIColor(Color.heatmap80)
        case 0.3...0.4:
            return UIColor(Color.heatmap70)
        case 0.4...0.5:
            return UIColor(Color.heatmap60)
        case 0.5...0.6:
            return UIColor(Color.heatmap50)
        case 0.6...0.7:
            return UIColor(Color.heatmap40)
        case 0.7...0.8:
            return UIColor(Color.heatmap30)
        case 0.8...0.9:
            return UIColor(Color.heatmap20)
        case 0.9...1.0:
            return UIColor(Color.heatmap10)
        default:
            return UIColor.clear
        }
        
    }
    
}

class FixedSizeRectangleOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var points: [MKMapPoint]
    var count: Int
    var color: UIColor
    
    init(center: CLLocationCoordinate2D, width: Double, height: Double, count: Int, color: UIColor) {
        self.count = count
        self.color = color
        let centerPoint = MKMapPoint(center)
        
        let halfWidth = width / 2
        let halfHeight = height / 2
        
        let topLeft = MKMapPoint(x: centerPoint.x - halfWidth, y: centerPoint.y - halfHeight)
        let topRight = MKMapPoint(x: centerPoint.x + halfWidth, y: centerPoint.y - halfHeight)
        let bottomLeft = MKMapPoint(x: centerPoint.x - halfWidth, y: centerPoint.y + halfHeight)
        let bottomRight = MKMapPoint(x: centerPoint.x + halfWidth, y: centerPoint.y + halfHeight)
        
        self.points = [topLeft, topRight, bottomRight, bottomLeft]
        
        let rect = MKMapRect(x: topLeft.x, y: topLeft.y, width: width, height: height)
        self.boundingMapRect = rect
        self.coordinate = center
    }
}
