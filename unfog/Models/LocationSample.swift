import Foundation
import CoreLocation

struct LocationSample: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    let timestamp: Date

    static func mockSamples() -> [LocationSample] {
        let base = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        return stride(from: 0.0, through: 1.0, by: 0.1).map { idx in
            let deltaLat = 0.01 * idx
            let deltaLon = 0.01 * sin(idx * .pi)
            let altitude = 20 + 500 * sin(idx * .pi * 1.2) + Double.random(in: -20...20)
            return LocationSample(
                coordinate: CLLocationCoordinate2D(
                    latitude: base.latitude + deltaLat,
                    longitude: base.longitude + deltaLon
                ),
                altitude: altitude,
                timestamp: Date().addingTimeInterval(idx * 600)
            )
        }
    }
}
