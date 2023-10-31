//
//  HeatmapView.swift
//  SoccerBeat
//
//  Created by daaan on 10/31/23.
//

import SwiftUI
import MapKit

// To attatch heatmap
// call HeatmapView with coordinate, polylineCoordinates
// HeatmapView(coordinate: CLLocationCoordinate2D(latitude, longitude),
// polylineCoordinates: [CLLocationCoordinate2D(latitude, longitude)])

struct HeatmapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    var polylineCoordinates: [CLLocationCoordinate2D]
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: coordinate,
                                                latitudinalMeters: 50,
                                                longitudinalMeters: 50)
        for polylineCoordinate in polylineCoordinates {
            print(polylineCoordinate)
            let polyline = MKPolyline(points: [MKMapPoint(CLLocationCoordinate2D(latitude: polylineCoordinate.latitude, longitude: polylineCoordinate.longitude)), MKMapPoint(CLLocationCoordinate2D(latitude: polylineCoordinate.latitude + 0.0000001, longitude: polylineCoordinate.longitude + 0.0000001))], count: 2)
            print(polyline)
            print(polylineCoordinate)
            mapView.addOverlay(polyline)
        }
        
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: HeatmapView
    
    init(_ parent: HeatmapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyDot = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyDot)
            renderer.strokeColor = .blue
            renderer.lineWidth = 20
            renderer.blendMode = .lighten
            return renderer
        }
        return MKOverlayRenderer()
    }
}