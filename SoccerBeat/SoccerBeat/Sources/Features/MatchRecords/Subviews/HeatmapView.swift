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
//    let centerCoordinate: CLLocationCoordinate2D
//    let routes: [CLLocationCoordinate2D]
    let mapView = MKMapView()
    let workout: WorkoutData
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        // Keep the heatmap as a fixed visualization and let the parent TabView handle gestures.
        mapView.isUserInteractionEnabled = false
        
        let centerCoordinate = CLLocationCoordinate2D(
            latitude: workout.center[0],
            longitude: workout.center[1]
        )
        
        mapView.region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        
        mapView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        // Create heatmap overlay
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
                
                // Draw smaller sized rectangle inside each grid
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
        
        for routePoint in workout.route {
            let mapPoint = MKMapPoint(routePoint)
            
            let col = Int((mapPoint.x - initialx) / squareSize)
            let row = Int((mapPoint.y - initialy) / squareSize)
            
            if row >= 0 && row < gridSize && col >= 0 && col < gridSize {
                gridCount[row][col] += 1
            }
        }
        
        // Calculate maxCount and medianCount
        let flatGridCount = gridCount.flatMap { $0 }
        let maxCount = flatGridCount.max() ?? 1
        let medianCount = flatGridCount.sorted()[flatGridCount.count / 2]
                
        for row in 0..<gridSize+1 {
            for col in 0..<gridSize+1 {
                
                let mapPointx = initialx + (squareSize * Double(col))
                let mapPointy = initialy + (squareSize * Double(row))
                
                let mapPoint = MKMapPoint(x: mapPointx, y: mapPointy)
                let coordinate = mapPoint.coordinate
                
                let squareCenter = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                //  Calculate ratio of number of data using log function within a grid
                let normalizedCount = normalizedCount(gridCount[row][col], maxCount: maxCount, medianCount: medianCount)
                
                let color = colorForNormalizedCount(normalizedCount)
                
                let overlay = FixedSizeRectangleOverlay(center: squareCenter, width: squareSize, height: squareSize, count: gridCount[row][col], color: color)
                
                overlays.append(overlay)
            }
        }
        return overlays
    }
    
    // In order to handle unevenly distributed data, multiple scales are used.
    // Linear scale
    func normalizedCount(_ count: Int, maxCount: Int, medianCount: Int) -> Double {
        if count <= 1 {
            return 0
        }
        if Double(maxCount) > Double(medianCount) * 5 {
            // Log scale for skewed data
            return log(Double(count) + 1) / log(Double(maxCount) + 1)
        } else {
            // Linear scale for evenly distributed data
            return Double(count) / Double(maxCount)
        }
    }

    func colorForNormalizedCount(_ normalizedCount: Double) -> UIColor {
        
        switch normalizedCount {
        case 0:
            return UIColor.clear
        case 0..<0.05:
            return UIColor(Color.heatmap90)
        case 0.05..<0.1:
            return UIColor(Color.heatmap80)
        case 0.1..<0.2:
            return UIColor(Color.heatmap70)
        case 0.2..<0.3:
            return UIColor(Color.heatmap60)
        case 0.3..<0.4:
            return UIColor(Color.heatmap50)
        case 0.4..<0.55:
            return UIColor(Color.heatmap40)
        case 0.55..<0.7:
            return UIColor(Color.heatmap30)
        case 0.7..<0.85:
            return UIColor(Color.heatmap20)
        case 0.85...1.0:
            return UIColor(Color.heatmap10)
        default:
            return UIColor.clear
        }
        
    }
    
}

extension HeatmapView {
    // targetSize 파라미터 추가
    func shootSnapshot(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // let size = mapView.frame.size == .zero ? UIScreen.main.bounds.size : mapView.frame.size // 기존 size 계산 제거
        let center = CLLocationCoordinate2D(latitude: workout.center[0], longitude: workout.center[1])

        let options = MKMapSnapshotter.Options()
        // 파라미터로 받은 targetSize 사용
        options.size = targetSize
        options.showsBuildings = false // 빌딩 표시는 필요 없으므로 false
        options.region = MKCoordinateRegion(center: center, latitudinalMeters: 150, longitudinalMeters: 150) // 기존 region 사용
        options.mapType = .mutedStandard // 스크린샷과 유사한 스타일

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("❌ Failed to create snapshot: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let centerCoordinate = CLLocationCoordinate2D(latitude: self.workout.center[0], longitude: self.workout.center[1])
            // 오버레이는 스냅샷 크기와 무관하게 데이터 기반으로 생성됨
            let overlays = self.createHeatmapOverlays(center: centerCoordinate, gridSize: 30, squareSize: 50)

            let renderer = UIGraphicsImageRenderer(size: options.size) // options.size 사용
            let image = renderer.image { context in
                snapshot.image.draw(at: .zero)

                for overlay in overlays {
                    let points = overlay.points.map { mapPoint in
                        snapshot.point(for: mapPoint.coordinate)
                    }

                    guard points.count == 4 else { continue }

                    let shrinkFactor: CGFloat = 0.8
                    let centerX = points.reduce(0) { $0 + $1.x } / CGFloat(points.count)
                    let centerY = points.reduce(0) { $0 + $1.y } / CGFloat(points.count)

                    let shrunkenPoints = points.map { point -> CGPoint in
                        let newX = centerX + (point.x - centerX) * shrinkFactor
                        let newY = centerY + (point.y - centerY) * shrinkFactor
                        return CGPoint(x: newX, y: newY)
                    }

                    let path = UIBezierPath()
                    path.move(to: shrunkenPoints[0])
                    for i in 1..<shrunkenPoints.count {
                        path.addLine(to: shrunkenPoints[i])
                    }
                    path.close()

                    overlay.color.setFill()
                    path.fill()
                }
            }
            print("✅ HeatmapView.shootSnapshot: 맵 스냅샷 생성 완료 (Size: \(options.size))")
            completion(image)
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
