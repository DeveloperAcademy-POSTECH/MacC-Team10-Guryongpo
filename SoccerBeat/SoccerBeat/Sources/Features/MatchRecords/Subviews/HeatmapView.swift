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
    @Binding var slider: Double
    let coordinate: CLLocationCoordinate2D
    let polylineCoordinates: [CLLocationCoordinate2D]
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        for idx in polylineCoordinates.indices {
            if idx % 10 == 0 {
                let index = Int(Double(idx) * slider)
                let polyline = MKPolyline(points: [
                    MKMapPoint(CLLocationCoordinate2D(latitude: polylineCoordinates[index].latitude,
                                                      longitude: polylineCoordinates[index].longitude)),
                    MKMapPoint(CLLocationCoordinate2D(latitude: polylineCoordinates[index].latitude + 0.0000001,
                                                      longitude: polylineCoordinates[index].longitude + 0.0000001))
                ], count: 2)
                uiView.addOverlay(polyline)
                print("Overlay added")
                print("index: ", index)
            }
        }
        
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(center: coordinate,
                                                latitudinalMeters: 100,
                                                longitudinalMeters: 100)
        
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
            renderer.strokeColor = .red
            renderer.alpha = CGFloat(0.3)
            renderer.lineWidth = 30
            renderer.blendMode = .lighten
            return renderer
        }
        return MKOverlayRenderer()
    }
}
