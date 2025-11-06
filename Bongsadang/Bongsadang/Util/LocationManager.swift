
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
        checkLocationAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }

    private func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            locationError = "위치 서비스가 제한되어 있습니다."
        case .denied:
            locationError = "위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            locationError = nil
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        locationError = "위치 정보를 가져올 수 없습니다."
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        checkLocationAuthorization()
    }
}
