//
//  LocationView.swift
//  SoccerBeat
//
//  Created by Henry's Mac on 11/9/24.
//

import SwiftUI
import MapKit

struct LocationView: UIViewRepresentable {
    @Binding var slider: Double
    let centerCoordinate: CLLocationCoordinate2D
    let routes: [CLLocationCoordinate2D]
    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        
        let coordinates = Array(routes).enumerated()
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

        let convertIndex = Int(Double(routes.count - 1) * slider)
        if (convertIndex < routes.count - 1) {
            let coordinates = routes[convertIndex]
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
    var parent: LocationView
    var currentPoint: MKOverlayRenderer?

    init(_ parent: LocationView) {
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
