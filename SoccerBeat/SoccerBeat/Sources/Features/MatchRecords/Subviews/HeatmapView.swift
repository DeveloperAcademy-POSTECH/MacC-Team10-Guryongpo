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
    let mapView = MKMapView()

    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        if slider == 0 {
         let polyline = MKPolyline()
            polyline.title = "-1"
            uiView.addOverlay(polyline)
        } else {
            let convertIndex = Int(Double(polylineCoordinates.count) * slider)
            let polyline = MKPolyline(coordinates: Array(polylineCoordinates[0..<convertIndex]),
                                      count: convertIndex)
            polyline.title = String(convertIndex)
            uiView.addOverlay(polyline)
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
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
    var mkoverlayRenderer: [MKOverlayRenderer]
    
    init(_ parent: HeatmapView) {
        self.parent = parent
        self.mkoverlayRenderer = []
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        mkoverlayRenderer.alpha = 0.0
        if let routePolyDot = overlay as? MKPolyline {
            if let curIndexString = overlay.title, let prevIndexString = mkoverlayRenderer.last?.overlay.title {
                let curIndex = Int(curIndexString ?? "0")!
                let prevIndex = Int(prevIndexString ?? "0")!
                if curIndex < prevIndex {
                    mkoverlayRenderer.forEach { overlay in
                        overlay.alpha = 0.0
                    }
                    mkoverlayRenderer = []
                }
                if curIndex == -1 { // slider value == 0
                    return MKOverlayRenderer()
                }
            }
                let renderer = MKPolylineRenderer(polyline: routePolyDot)
                renderer.strokeColor = .red
                renderer.alpha = CGFloat(1.0)
                renderer.lineWidth = 8
                renderer.blendMode = .lighten
                self.mkoverlayRenderer.append(renderer)
                return renderer
        }
        return MKOverlayRenderer()
    }
}
