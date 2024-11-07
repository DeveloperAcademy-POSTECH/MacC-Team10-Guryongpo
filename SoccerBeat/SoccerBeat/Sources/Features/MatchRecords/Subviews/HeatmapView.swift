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
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: centerCoordinate,
                                            latitudinalMeters: 100,
                                            longitudinalMeters: 100)
        mapView.setRegion(mapView.region, animated: false)
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
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
                let renderer = MKPolygonRenderer(polygon: MKPolygon(points: rectangleOverlay.points, count: rectangleOverlay.points.count))
                
                switch rectangleOverlay.count {
                case 0:
                    renderer.fillColor = UIColor.clear
                case 1:
                    renderer.fillColor = UIColor.yellow.withAlphaComponent(0.6)
//                    renderer.strokeColor = UIColor.yellow
//                    renderer.lineWidth = 1
                case 2:
                    renderer.fillColor = UIColor.orange.withAlphaComponent(0.6)
//                    renderer.strokeColor = UIColor.orange
//                    renderer.lineWidth = 1
                default:
                    renderer.fillColor = UIColor.red.withAlphaComponent(0.6)
//                    renderer.strokeColor = UIColor.red
//                    renderer.lineWidth = 1
                }
                
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
        
        for row in 0..<gridSize+1 {
            for col in 0..<gridSize+1 {
                
                let mapPointx = initialx + (squareSize * Double(col))
                let mapPointy = initialy + (squareSize * Double(row))
                
                let mapPoint = MKMapPoint(x: mapPointx, y: mapPointy)
                let coordinate = mapPoint.coordinate
                
                let squareCenter = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let overlay = FixedSizeRectangleOverlay(center: squareCenter, width: squareSize, height: squareSize, count: gridCount[row][col])
                
                if gridCount[row][col] != 0 {
                    print("Overlay at row \(row), col \(col) has count: \(gridCount[row][col])")
                }
                
                overlays.append(overlay)
            }
        }
        return overlays
    }
}

class FixedSizeRectangleOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var points: [MKMapPoint]
    var count: Int
    
    init(center: CLLocationCoordinate2D, width: Double, height: Double, count: Int) {
        self.count = count
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

//struct HeatmapView: UIViewRepresentable {
//    @Binding var slider: Double
//    let coordinate: CLLocationCoordinate2D
//    let polylineCoordinates: [CLLocationCoordinate2D]
//    let mapView = MKMapView()
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        
//        let convertIndex = Int(Double(polylineCoordinates.count - 1) * slider)
//        if (convertIndex < polylineCoordinates.count - 1) {
//            let coordinates = polylineCoordinates[convertIndex]
//            let pointStart = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude,
//                                                               longitude: coordinates.longitude))
//            let pointEnd = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude + 0.0000001,
//                                                             longitude: coordinates.longitude + 0.0000001))
//            let movePoint = MKPolyline(points: [pointStart, pointEnd], count: 2)
//            movePoint.title = String("Point")
//            uiView.addOverlay(movePoint)
//        }
//    }
//    
//    func makeUIView(context: Context) -> MKMapView {
//        
//        mapView.delegate = context.coordinator
//        mapView.region = MKCoordinateRegion(center: coordinate,
//                                                latitudinalMeters: 100,
//                                                longitudinalMeters: 100)
//        let coordinates = Array(polylineCoordinates).enumerated()
//            .filter { $0.offset % 5 == 0 && $0.element.latitude != 0}
//            .map { $0.element }
//        let polyline = MKPolyline(coordinates: coordinates,
//                                  count: coordinates.count)
//        mapView.addOverlay(polyline)
//        
//        if let coordinate = coordinates.first {
//            let pointStart = MKMapPoint(CLLocationCoordinate2D(latitude: coordinate.latitude,
//                                                               longitude: coordinate.longitude))
//            let pointEnd = MKMapPoint(CLLocationCoordinate2D(latitude: coordinate.latitude + 0.0000001,
//                                                             longitude: coordinate.longitude + 0.0000001))
//            let startPoint = MKPolyline(points: [pointStart, pointEnd], count: 2)
//            
//            startPoint.title = String("Point")
//            mapView.addOverlay(startPoint)
//        }
//            
//        return mapView
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//}
//
//class Coordinator: NSObject, MKMapViewDelegate {
//    var parent: HeatmapView
//    var currentPoint: MKOverlayRenderer?
//    
//    init(_ parent: HeatmapView) {
//        self.parent = parent
//        self.currentPoint = nil
//    }
//    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let routePolyDot = overlay as? MKPolyline {
//            if routePolyDot.title == "Point" {
//                // Current Position Point
//                self.currentPoint?.alpha = 0.0
//                let renderer = MKPolylineRenderer(polyline: routePolyDot)
//                renderer.strokeColor = .white
//                renderer.alpha = CGFloat(1.0)
//                renderer.lineWidth = 20
//                renderer.blendMode = .lighten
//                self.currentPoint = renderer
//                return renderer
//            } else {
//                // Full line
//                let renderer = MKPolylineRenderer(polyline: routePolyDot)
//                renderer.strokeColor = .cyan
//                renderer.alpha = CGFloat(1.0)
//                renderer.lineWidth = 8
//                renderer.blendMode = .lighten
//                renderer.alpha = 0.8
//                return renderer
//            }
//        }
//        let renderer = MKOverlayRenderer()
//        return renderer
//    }
//}
