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
        mapView.isUserInteractionEnabled = true
        
        let centerCoordinate = CLLocationCoordinate2D(
            latitude: workout.center[0],
            longitude: workout.center[1]
        )

        mapView.region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        // Rotate the existing camera so the established 150 m region remains unchanged.
        mapView.camera.heading = heatmapHeading(center: centerCoordinate)
        
        // Create heatmap overlay
        if let overlay = createHeatmapOverlay(center: centerCoordinate) {
            mapView.addOverlay(overlay)
        }
                    
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
            if let heatmap = overlay as? HeatmapOverlay {
                return HeatmapRenderer(overlay: heatmap)
            }
            return MKOverlayRenderer()
        }
    }

    func createHeatmapOverlay(center: CLLocationCoordinate2D) -> HeatmapOverlay? {
        let density = HeatmapDensity(samples: workout.heatmapSamples,
                                     centerLatitude: center.latitude,
                                     centerLongitude: center.longitude,
                                     pausedIntervals: workout.heatmapPausedIntervals)
        let intensities = density.intensities
        guard intensities.contains(where: { $0 > 0 }) else { return nil }
        var pixels: [UInt8] = []
        pixels.reserveCapacity(intensities.count * 4)
        for intensity in intensities {
            // Premultiplied RGBA: continuous yellow -> orange -> red, with faint tails.
            let alpha = intensity > 0 ? 0.65 * min(intensity / 0.1, 1) : 0
            pixels += [UInt8(255 * alpha), UInt8((247 - 188 * intensity) * alpha),
                       UInt8(48 * alpha), UInt8(255 * alpha)]
        }
        let side = HeatmapDensity.side
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 32,
                                  bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        else { return nil }
        return HeatmapOverlay(image: image, center: center)
    }
}

extension HeatmapView {
    func heatmapHeading(center: CLLocationCoordinate2D) -> CLLocationDirection {
        let centerMapPoint = MKMapPoint(center)
        let nearbyPoints = workout.route.compactMap { coordinate -> MKMapPoint? in
            guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }

            let mapPoint = MKMapPoint(coordinate)
            return centerMapPoint.distance(to: mapPoint) <= 75 ? mapPoint : nil
        }
        let distinctPoints = nearbyPoints.reduce(into: [MKMapPoint]()) { points, point in
            guard points.count < 3,
                  !points.contains(where: { $0.x == point.x && $0.y == point.y }) else { return }
            points.append(point)
        }

        // Sparse or isotropic routes have no stable orientation, so keep the map north-up.
        guard distinctPoints.count >= 3 else { return 0 }

        let pointCount = Double(nearbyPoints.count)
        let meanX = nearbyPoints.reduce(0) { $0 + $1.x } / pointCount
        let meanY = nearbyPoints.reduce(0) { $0 + $1.y } / pointCount
        let covariance = nearbyPoints.reduce(into: (xx: 0.0, xy: 0.0, yy: 0.0)) { result, point in
            let deltaX = point.x - meanX
            let deltaY = point.y - meanY
            result.xx += deltaX * deltaX
            result.xy += deltaX * deltaY
            result.yy += deltaY * deltaY
        }
        let covarianceXX = covariance.xx / pointCount
        let covarianceXY = covariance.xy / pointCount
        let covarianceYY = covariance.yy / pointCount
        let trace = covarianceXX + covarianceYY
        let discriminant = hypot(covarianceXX - covarianceYY, 2 * covarianceXY)
        let principalVariance = (trace + discriminant) / 2
        let secondaryVariance = max((trace - discriminant) / 2, .ulpOfOne)

        guard principalVariance / secondaryVariance >= 1.2 else { return 0 }

        // PCA finds the route's undirected dominant axis without depending on its start or end.
        let axisAngle = 0.5 * atan2(2 * covarianceXY, covarianceXX - covarianceYY)
        var heading = axisAngle * 180 / .pi
        heading.formTruncatingRemainder(dividingBy: 180)
        return heading < 0 ? heading + 180 : heading
    }

    // targetSize 파라미터 추가
    func shootSnapshot(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // let size = mapView.frame.size == .zero ? UIScreen.main.bounds.size : mapView.frame.size // 기존 size 계산 제거
        let center = CLLocationCoordinate2D(latitude: workout.center[0], longitude: workout.center[1])

        let options = MKMapSnapshotter.Options()
        // 파라미터로 받은 targetSize 사용
        options.size = targetSize
        options.showsBuildings = false // 빌딩 표시는 필요 없으므로 false
        options.region = MKCoordinateRegion(center: center, latitudinalMeters: 150, longitudinalMeters: 150) // 기존 region 사용
        // Match the live heatmap orientation without replacing the established 150 m region.
        options.camera.heading = heatmapHeading(center: center)
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
            let overlay = self.createHeatmapOverlay(center: centerCoordinate)

            let renderer = UIGraphicsImageRenderer(size: options.size) // options.size 사용
            let image = renderer.image { context in
                snapshot.image.draw(at: .zero)

                if let overlay = overlay {
                    let rect = overlay.boundingMapRect
                    let topLeft = snapshot.point(for: MKMapPoint(x: rect.minX, y: rect.minY).coordinate)
                    let topRight = snapshot.point(for: MKMapPoint(x: rect.maxX, y: rect.minY).coordinate)
                    let bottomLeft = snapshot.point(for: MKMapPoint(x: rect.minX, y: rect.maxY).coordinate)
                    let side = CGFloat(HeatmapDensity.side)
                    let transform = CGAffineTransform(a: (topRight.x - topLeft.x) / side,
                                                      b: (topRight.y - topLeft.y) / side,
                                                      c: (bottomLeft.x - topLeft.x) / side,
                                                      d: (bottomLeft.y - topLeft.y) / side,
                                                      tx: topLeft.x, ty: topLeft.y)
                    context.cgContext.concatenate(transform)
                    HeatmapRenderer.drawImage(overlay.image, in: CGRect(x: 0, y: 0, width: side, height: side),
                                              context: context.cgContext)
                }
            }
            print("✅ HeatmapView.shootSnapshot: 맵 스냅샷 생성 완료 (Size: \(options.size))")
            completion(image)
        }
    }
}

// A single interpolated texture avoids cell seams and thousands of map renderers.
class HeatmapOverlay: NSObject, MKOverlay {
    let image: CGImage
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect

    init(image: CGImage, center: CLLocationCoordinate2D) {
        self.image = image
        self.coordinate = center
        let centerPoint = MKMapPoint(center)
        let width = Double(HeatmapDensity.side) * HeatmapDensity.cellSize * MKMapPointsPerMeterAtLatitude(center.latitude)
        self.boundingMapRect = MKMapRect(x: centerPoint.x - width / 2, y: centerPoint.y - width / 2,
                                        width: width, height: width)
    }
}

class HeatmapRenderer: MKOverlayRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let heatmap = overlay as? HeatmapOverlay else { return }
        Self.drawImage(heatmap.image, in: rect(for: heatmap.boundingMapRect), context: context)
    }

    static func drawImage(_ image: CGImage, in rect: CGRect, context: CGContext) {
        context.saveGState()
        context.interpolationQuality = .high
        context.translateBy(x: rect.minX, y: rect.maxY)
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: CGRect(origin: .zero, size: rect.size))
        context.restoreGState()
    }
}
