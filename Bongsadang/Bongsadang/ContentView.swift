import SwiftUI
import MapboxMaps
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
}

struct MapboxView: UIViewRepresentable {
    private let token = "sk.eyJ1IjoiYm9uZ3NhZGFuZyIsImEiOiJjbWhtMjZ4a2oyMGhyMm1zNzdudGhvbzhmIn0.g9zLfdJDDgs52jOs6jmZRA"
    private let styleURL = "mapbox://styles/bongsadang/cmhlxqa1d00k101si5frs0lkb"
    @ObservedObject var locationManager: LocationManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var hasMovedToUserLocation = false
    }

    func makeUIView(context: Context) -> MapView {
        let mapView = MapView(frame: .zero)
        
        mapView.mapboxMap.loadStyleURI(StyleURI(rawValue: styleURL) ?? .streets)
        
        let puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(puckConfiguration)
        
        return mapView
    }

    func updateUIView(_ uiView: MapView, context: Context) {
        if let userLocation = locationManager.userLocation, !context.coordinator.hasMovedToUserLocation {
            let camera = CameraOptions(center: userLocation, zoom: 14)
            uiView.mapboxMap.setCamera(to: camera)
            context.coordinator.hasMovedToUserLocation = true
        }
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            MapboxView(locationManager: locationManager)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Text("봉사당 지도")
                        .font(.headline)
                    if locationManager.userLocation != nil {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
