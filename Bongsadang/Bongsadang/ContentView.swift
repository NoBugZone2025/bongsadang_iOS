import SwiftUI
import MapboxMaps
import CoreLocation
import Combine

// MARK: - 위치 관리 클래스
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
        print("📍 위치 업데이트: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 위치 권한 상태: \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ 위치 권한이 거부되었습니다")
        default:
            break
        }
    }
}

// MARK: - MapboxView
struct MapboxView: UIViewRepresentable {
    private let token = "sk.eyJ1IjoiYm9uZ3NhZGFuZyIsImEiOiJjbWhtMjZ4a2oyMGhyMm1zNzdudGhvbzhmIn0.g9zLfdJDDgs52jOs6jmZRA"
    private let styleURL = "mapbox://styles/bongsadang/cmhlxqa1d00k101si5frs0lkb"
    @ObservedObject var locationManager: LocationManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var hasMovedToUserLocation = false
        var cancellables = Set<AnyCancellable>()
    }

    func makeUIView(context: Context) -> MapView {
        // MapView 초기화
        let mapView = MapView(frame: .zero)
        
        // Access Token 설정
        MapboxOptions.accessToken = token
        
        // 스타일 로드
        mapView.mapboxMap.loadStyle(StyleURI(rawValue: styleURL) ?? .streets)
        
        // 스타일 로드 후 3D 건물 레이어 추가
        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            do {
                // 3D 건물 레이어 추가
                var layer = FillExtrusionLayer(id: "3d-buildings", source: "composite")
                layer.sourceLayer = "building"
                layer.filter = Exp(.eq) {
                    Exp(.geometryType)
                    "Polygon"
                }
                layer.minZoom = 15
                layer.fillExtrusionColor = .constant(StyleColor(.lightGray))
                layer.fillExtrusionHeight = .expression(Exp(.get) { "height" })
                layer.fillExtrusionBase = .expression(Exp(.get) { "min_height" })
                layer.fillExtrusionOpacity = .constant(0.8)
                
                try mapView.mapboxMap.addLayer(layer)
            } catch {
                print("Error adding 3D buildings layer: \(error)")
            }
        }.store(in: &context.coordinator.cancellables)

        // 위치 추적 활성화
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingEnabled = true
        
        return mapView
    }

    func updateUIView(_ uiView: MapView, context: Context) {
        if let userLocation = locationManager.userLocation,
           !context.coordinator.hasMovedToUserLocation {
            
            print("🎥 카메라 이동: \(userLocation.latitude), \(userLocation.longitude)")
            
            // 3D 시점으로 카메라 이동
            let camera = CameraOptions(
                center: userLocation,
                zoom: 17,          // 확대 정도
                bearing: 0,        // 회전각 (0 = 북쪽)
                pitch: 45          // 기울기 (45도 = 적당히 위에서)
            )
            
            uiView.camera.ease(to: camera, duration: 1.5)
            context.coordinator.hasMovedToUserLocation = true
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 지도
            MapboxView(locationManager: locationManager)
                .ignoresSafeArea()
            
            // 네비게이션바
            VStack(spacing: 0) {
                Color.white
                    .ignoresSafeArea(.container, edges: .top) // Safe Area 위까지 확장
                    .frame(height: 0)
                
                HStack(spacing: 8) {
                    Image("로고")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                        .padding(.leading, 11)
                        .padding(.top, 11)
                    
                    Image("logoText")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                        .padding(.top, 11)
                    
                    Spacer()
                }
                .frame(height: 58)
                .background(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2) // 살짝 입체감 추가
            }
            
            // 하단 정보
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

// MARK: - Preview
#Preview {
    ContentView()
}
