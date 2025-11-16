import SwiftUI
import Foundation
import MapKit
import Combine

final class MapViewModel: ObservableObject {
    enum DisplayMode: String, CaseIterable, Identifiable {
        case visited = "Visited"
        case altitude = "Altitude"

        var id: String { rawValue }
    }

    @Published var region: MKCoordinateRegion
    @Published var samples: [LocationSample]
    @Published var displayMode: DisplayMode = .visited
    @Published var isRecording = false
    @Published var altitudeRange: ClosedRange<Double> = 0...1

    private var cancellables = Set<AnyCancellable>()
    private let locationManager: LocationManager

    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        let initialSamples = LocationSample.mockSamples()
        self.samples = initialSamples
        let initialCenter = initialSamples.first?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        self.region = MKCoordinateRegion(center: initialCenter,
                                         span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        calculateAltitudeRange()

        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationManager.startTracking()
                }
            }
            .store(in: &cancellables)

        locationManager.$latestLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.append(location: location)
            }
            .store(in: &cancellables)
    }

    func requestPermissionIfNeeded() {
        locationManager.requestPermission()
    }

    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            // In production, configure background updates and activity types here
            locationManager.startTracking()
        } else {
            locationManager.stopTracking()
        }
    }

    func recenter() {
        guard let coordinate = samples.last?.coordinate else { return }
        withAnimation {
            region.center = coordinate
        }
    }

    func legendGradient() -> Gradient {
        Gradient(colors: [Color.blue, Color.green, Color.yellow, Color.orange, Color.red])
    }

    private func append(location: CLLocation) {
        let sample = LocationSample(coordinate: location.coordinate,
                                    altitude: location.altitude,
                                    timestamp: location.timestamp)
        samples.append(sample)
        region.center = location.coordinate
        calculateAltitudeRange()
    }

    private func calculateAltitudeRange() {
        guard let min = samples.map({ $0.altitude }).min(),
              let max = samples.map({ $0.altitude }).max(),
              min != max else {
            altitudeRange = 0...1
            return
        }
        altitudeRange = min...max
    }

    func color(for altitude: CLLocationDistance) -> Color {
        let range = altitudeRange
        guard range.upperBound > range.lowerBound else { return .blue }
        let normalized = (altitude - range.lowerBound) / (range.upperBound - range.lowerBound)
        switch normalized {
        case ..<0.25: return .blue
        case ..<0.5: return .green
        case ..<0.75: return .yellow
        default: return .orange
        }
    }
}

