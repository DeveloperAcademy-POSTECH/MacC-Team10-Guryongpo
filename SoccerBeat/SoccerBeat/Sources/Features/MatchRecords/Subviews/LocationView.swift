//
//  LocationView.swift
//  SoccerBeat
//
//  Created by Henry's Mac on 11/9/24.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @Binding var slider: Double
    @StateObject private var model: PlaybackModel
    let centerCoordinate: CLLocationCoordinate2D

    init(slider: Binding<Double>, workout: WorkoutData) {
        _slider = slider
        centerCoordinate = CLLocationCoordinate2D(latitude: workout.center[0], longitude: workout.center[1])
        _model = StateObject(wrappedValue: PlaybackModel(workout: workout))
    }

    var body: some View {
        let selection = model.timeline.selection(at: slider)
        VStack(spacing: 10) {
            LocationMapView(progress: slider, center: centerCoordinate, timeline: model.timeline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(15)
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text("경로 시작")
                    RouteScrubber(value: $slider, canSeek: model.timeline.canSeek,
                                  accessibilityTime: selection?.point.timestamp?.formatted(date: .omitted, time: .standard))
                        .frame(height: 44)
                    Text("경로 종료")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                Text(selection?.point.timestamp?.formatted(date: .omitted, time: .standard)
                     ?? (selection == nil ? "--" : slider.formatted(.percent.precision(.fractionLength(0)))))
                    .monospacedDigit()
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private final class PlaybackModel: ObservableObject {
        let timeline: RouteTimeline

        init(workout: WorkoutData) {
            timeline = RouteTimeline(samples: workout.heatmapSamples,
                                     fallback: workout.route.map {
                                         RouteTimeline.Point(latitude: $0.latitude, longitude: $0.longitude, timestamp: nil)
                                     }, pauses: workout.heatmapPausedIntervals)
        }
    }
}

/// Keep native touch tracking and accessibility while using the route colors and a football thumb.
private struct RouteScrubber: UIViewRepresentable {
    @Binding var value: Double
    let canSeek: Bool
    let accessibilityTime: String?

    func makeCoordinator() -> Coordinator { Coordinator(value: $value) }

    func makeUIView(context: Context) -> TimelineSlider {
        let slider = TimelineSlider(frame: .zero)
        slider.minimumValue = 0
        slider.maximumValue = 1
        let clear = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        slider.setMinimumTrackImage(clear, for: .normal)
        slider.setMaximumTrackImage(clear, for: .normal)
        let ball = UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28)).image { _ in
            UIImage(named: "SoccerBall")?.draw(in: CGRect(x: 0, y: 0, width: 28, height: 28))
        }
        slider.setThumbImage(ball, for: .normal)
        slider.setThumbImage(ball, for: .highlighted)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        slider.accessibilityLabel = String(localized: "경기 위치 탐색")
        return slider
    }

    func updateUIView(_ slider: TimelineSlider, context: Context) {
        context.coordinator.value = $value
        if !slider.isTracking { slider.value = Float(value) }
        slider.isEnabled = canSeek
        slider.alpha = canSeek ? 1 : 0.5
        slider.accessibilityValue = accessibilityTime ?? value.formatted(.percent.precision(.fractionLength(0)))
    }

    final class Coordinator: NSObject {
        var value: Binding<Double>
        init(value: Binding<Double>) { self.value = value }
        @objc func changed(_ slider: UISlider) { value.wrappedValue = Double(slider.value) }
    }

    final class TimelineSlider: UISlider {
        private let gradient = CAGradientLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            gradient.colors = LocationMapView.colors.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.cornerRadius = 2
            layer.insertSublayer(gradient, at: 0)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func layoutSubviews() {
            super.layoutSubviews()
            let track = trackRect(forBounds: bounds)
            let start = thumbRect(forBounds: bounds, trackRect: track, value: 0).midX
            let end = thumbRect(forBounds: bounds, trackRect: track, value: 1).midX
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradient.frame = CGRect(x: start, y: track.midY - 2, width: end - start, height: 4)
            CATransaction.commit()
        }
    }
}

/// Draw every route segment with the same screen-space width at each map zoom level.
private final class RouteRenderer: MKOverlayRenderer {
    private let polyline: MKPolyline
    private let gradients: [CGGradient]

    init(polyline: MKPolyline, colors: [UIColor]) {
        self.polyline = polyline
        let space = CGColorSpaceCreateDeviceRGB()
        gradients = zip(colors, colors.dropFirst()).map {
            CGGradient(colorsSpace: space, colors: [$0.cgColor, $1.cgColor] as CFArray, locations: [0, 1])!
        }
        super.init(overlay: polyline)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let width = 4 / zoomScale
        let points = polyline.points()
        context.saveGState()
        context.clip(to: rect(for: mapRect))
        context.setLineWidth(width)
        context.setLineCap(.round)
        for index in 0..<gradients.count {
            let start = point(for: points[index])
            let end = point(for: points[index + 1])
            guard start != end else { continue }
            let bounds = CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
                                width: abs(end.x - start.x), height: abs(end.y - start.y))
                .insetBy(dx: -width, dy: -width)
            guard bounds.intersects(rect(for: mapRect)) else { continue }
            context.saveGState()
            context.beginPath()
            context.move(to: start)
            context.addLine(to: end)
            context.replacePathWithStrokedPath()
            context.clip()
            context.drawLinearGradient(gradients[index], start: start, end: end,
                                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            context.restoreGState()
        }
        context.restoreGState()
    }
}

private struct LocationMapView: UIViewRepresentable {
    let progress: Double
    let center: CLLocationCoordinate2D
    let timeline: RouteTimeline
    static let colors: [UIColor] = [.systemTeal, .systemBlue, .systemPurple, .systemPink]

    func makeCoordinator() -> Coordinator { Coordinator(timeline: timeline) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.region = MKCoordinateRegion(center: center, latitudinalMeters: 150, longitudinalMeters: 150)
        context.coordinator.install(on: map, progress: progress)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.movePointer(on: map, progress: progress)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let timeline: RouteTimeline
        let pointer = MKPointAnnotation()
        private var segmentIndices: [ObjectIdentifier: [Int]] = [:]

        init(timeline: RouteTimeline) {
            self.timeline = timeline
            super.init()
            pointer.title = String(localized: "현재 위치")
        }

        func install(on map: MKMapView, progress: Double) {
            let points = timeline.points
            guard let first = points.first, let last = points.last else { return }
            var segments: [[Int]] = []
            for index in points.indices {
                if !timeline.connectsToPrevious[index] { segments.append([]) }
                segments[segments.count - 1].append(index)
            }
            // A single recorded fix has no line segment, but is still real location data.
            for indices in segments where indices.count == 1 {
                let index = indices[0]
                map.addAnnotation(RecordedFix(point: points[index], progress: timeline.progress(at: index)))
            }
            for indices in segments where indices.count > 1 {
                let coordinates = indices.map { coordinate(points[$0]) }
                // Stationary samples have time but no drawable route length.
                guard coordinates.contains(where: {
                    $0.latitude != coordinates[0].latitude || $0.longitude != coordinates[0].longitude
                }) else { continue }
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                segmentIndices[ObjectIdentifier(polyline)] = indices
                map.addOverlay(polyline)
            }
            if points.count > 1 {
                let distance = MKMapPoint(coordinate(first)).distance(to: MKMapPoint(coordinate(last)))
                if distance < 3 {
                    map.addAnnotation(Endpoint(coordinate: coordinate(first), kind: .combined))
                } else {
                    map.addAnnotations([Endpoint(coordinate: coordinate(first), kind: .start),
                                        Endpoint(coordinate: coordinate(last), kind: .finish)])
                }
            }
            let selection = timeline.selection(at: progress)
            pointer.coordinate = coordinate(selection?.point ?? first)
            map.addAnnotation(pointer)
            // Fit once; scrubbing never changes the user's pan or zoom.
            let bounds = points.reduce(MKMapRect.null) {
                let point = MKMapPoint(coordinate($1))
                return $0.union(MKMapRect(x: point.x, y: point.y, width: 1, height: 1))
            }
            let minimum = 150 * MKMapPointsPerMeterAtLatitude(first.latitude)
            let width = max(bounds.width, minimum)
            let height = max(bounds.height, minimum)
            map.setVisibleMapRect(MKMapRect(x: bounds.midX - width / 2, y: bounds.midY - height / 2,
                                           width: width, height: height),
                                  edgePadding: UIEdgeInsets(top: 48, left: 28, bottom: 28, right: 28), animated: false)
        }

        func movePointer(on map: MKMapView, progress: Double) {
            guard let selection = timeline.selection(at: progress) else { return }
            let target = coordinate(selection.point)
            guard pointer.coordinate.latitude != target.latitude || pointer.coordinate.longitude != target.longitude else { return }
            UIView.animate(withDuration: 0.08, delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) {
                self.pointer.coordinate = target
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline,
                  let indices = segmentIndices[ObjectIdentifier(polyline)] else { return MKOverlayRenderer(overlay: overlay) }
            return RouteRenderer(polyline: polyline, colors: indices.map { timeColor(timeline.progress(at: $0)) })
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation === pointer {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "current-route-position")
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "current-route-position")
                view.annotation = annotation
                view.frame.size = CGSize(width: 22, height: 22)
                view.backgroundColor = .white
                view.layer.cornerRadius = 11
                view.layer.borderWidth = 3
                view.layer.borderColor = UIColor.systemTeal.cgColor
                view.layer.shadowColor = UIColor.black.cgColor
                view.layer.shadowOpacity = 0.4
                view.layer.shadowRadius = 3
                view.displayPriority = .required
                view.zPriority = .max
                view.isAccessibilityElement = true
                view.accessibilityLabel = String(localized: "현재 위치")
                return view
            }
            if let fix = annotation as? RecordedFix {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "route-recorded-fix")
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "route-recorded-fix")
                view.annotation = annotation
                view.frame.size = CGSize(width: 8, height: 8)
                view.backgroundColor = timeColor(fix.progress)
                view.layer.cornerRadius = 4
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.white.cgColor
                view.displayPriority = .defaultLow
                view.canShowCallout = true
                view.isAccessibilityElement = true
                view.accessibilityLabel = fix.title
                return view
            }
            guard let endpoint = annotation as? Endpoint else { return nil }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "route-endpoint")
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "route-endpoint")
            view.annotation = annotation
            let color = endpoint.kind == .start ? LocationMapView.colors[0]
                : endpoint.kind == .finish ? LocationMapView.colors[3] : .systemPurple
            let symbol = endpoint.kind == .start ? "play.fill"
                : endpoint.kind == .finish ? "flag.checkered" : "arrow.triangle.2.circlepath"
            view.image = endpointImage(color: color, symbol: symbol)
            view.centerOffset = CGPoint(x: 0, y: -16)
            view.canShowCallout = true
            view.displayPriority = .required
            view.isAccessibilityElement = true
            view.accessibilityLabel = endpoint.title
            return view
        }

        private func endpointImage(color: UIColor, symbol: String) -> UIImage {
            UIGraphicsImageRenderer(size: CGSize(width: 24, height: 32)).image { _ in
                color.setFill()
                UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: 22, height: 22)).fill()
                let tip = UIBezierPath()
                tip.move(to: CGPoint(x: 8, y: 20))
                tip.addLine(to: CGPoint(x: 16, y: 20))
                tip.addLine(to: CGPoint(x: 12, y: 32))
                tip.close()
                tip.fill()
                UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))?
                    .withTintColor(.white, renderingMode: .alwaysOriginal)
                    .draw(in: CGRect(x: 6, y: 6, width: 12, height: 12))
            }
        }

        private func coordinate(_ point: RouteTimeline.Point) -> CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        }

        private func timeColor(_ progress: Double) -> UIColor {
            let value = min(max(progress, 0), 1) * Double(LocationMapView.colors.count - 1)
            let index = min(Int(value), LocationMapView.colors.count - 2)
            let fraction = CGFloat(value - Double(index))
            var r0: CGFloat = 0, g0: CGFloat = 0, b0: CGFloat = 0, a0: CGFloat = 0
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            LocationMapView.colors[index].getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            LocationMapView.colors[index + 1].getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            return UIColor(red: r0 + (r1 - r0) * fraction, green: g0 + (g1 - g0) * fraction,
                           blue: b0 + (b1 - b0) * fraction, alpha: 1)
        }
    }
}

private final class Endpoint: MKPointAnnotation {
    enum Kind { case start, finish, combined }
    let kind: Kind

    init(coordinate: CLLocationCoordinate2D, kind: Kind) {
        self.kind = kind
        super.init()
        self.coordinate = coordinate
        switch kind {
        case .start: title = String(localized: "경로 시작")
        case .finish: title = String(localized: "경로 종료")
        case .combined: title = String(localized: "시작·종료")
        }
    }
}


private final class RecordedFix: MKPointAnnotation {
    let progress: Double

    init(point: RouteTimeline.Point, progress: Double) {
        self.progress = progress
        super.init()
        coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        title = String(localized: "GPS 기록 지점")
        subtitle = point.timestamp?.formatted(date: .omitted, time: .standard)
    }
}
