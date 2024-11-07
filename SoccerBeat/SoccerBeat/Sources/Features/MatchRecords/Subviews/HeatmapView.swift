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
    @Binding var slider: Double
    let coordinate: CLLocationCoordinate2D
    let polylineCoordinates: [CLLocationCoordinate2D]
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: coordinate,
                                                latitudinalMeters: 100,
                                                longitudinalMeters: 100)
        mapView.setRegion(mapView.region, animated: false)
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        let coordinates = Array(polylineCoordinates).enumerated()
            .filter { $0.offset % 5 == 0 && $0.element.latitude != 0}
            .map { $0.element }
        let polyline = MKPolyline(coordinates: coordinates,
                                  count: coordinates.count)
        mapView.addOverlay(polyline)
        
        if let coordinate = coordinates.first {
            let pointStart = MKMapPoint(CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                               longitude: coordinate.longitude))
            let pointEnd = MKMapPoint(CLLocationCoordinate2D(latitude: coordinate.latitude + 0.0000001,
                                                             longitude: coordinate.longitude + 0.0000001))
            let startPoint = MKPolyline(points: [pointStart, pointEnd], count: 2)
            
            startPoint.title = String("Point")
            mapView.addOverlay(startPoint)
        }
            
        return mapView
    }
    

    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        let convertIndex = Int(Double(polylineCoordinates.count - 1) * slider)
        if (convertIndex < polylineCoordinates.count - 1) {
            let coordinates = polylineCoordinates[convertIndex]
            let pointStart = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude,
                                                               longitude: coordinates.longitude))
            let pointEnd = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude + 0.0000001,
                                                             longitude: coordinates.longitude + 0.0000001))
            let movePoint = MKPolyline(points: [pointStart, pointEnd], count: 2)
            movePoint.title = String("Point")
            uiView.addOverlay(movePoint)
        }
    }
    

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: HeatmapView
    var currentPoint: MKOverlayRenderer?
    
    init(_ parent: HeatmapView) {
        self.parent = parent
        self.currentPoint = nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyDot = overlay as? MKPolyline {
            if routePolyDot.title == "Point" {
                // Current Position Point
                self.currentPoint?.alpha = 0.0
                let renderer = MKPolylineRenderer(polyline: routePolyDot)
                renderer.strokeColor = .white
                renderer.alpha = CGFloat(1.0)
                renderer.lineWidth = 20
                renderer.blendMode = .lighten
                self.currentPoint = renderer
                return renderer
            } else {
                // Full line
                let renderer = MKPolylineRenderer(polyline: routePolyDot)
                renderer.strokeColor = .cyan
                renderer.alpha = CGFloat(1.0)
                renderer.lineWidth = 8
                renderer.blendMode = .lighten
                renderer.alpha = 0.8
                return renderer
            }
        }
        let renderer = MKOverlayRenderer()
        return renderer
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
