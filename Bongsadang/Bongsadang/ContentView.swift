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
        let configuration = Puck2DConfiguration(topImage: UIImage(named: "mylocation"), bearingImage: UIImage(named: "mylocation"))
        mapView.location.options.puckType = .puck2D(configuration)
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
            
            // 검색창 (네비게이션 바 아래 9pt 떨어진 위치)
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    Text("원하는 지역을 입력하세요")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color(hex: "FFF8DC"))
                .cornerRadius(16)
                .padding(.horizontal, 10)
                .padding(.top, 67) // 네비게이션 바(58) + 간격(9)
                
                Spacer()
            }
            
            // 하단 탭바
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Home 탭
                    Button(action: {
                        // Home 액션
                    }) {
                        Image("home")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Shop 탭
                    Button(action: {
                        // Shop 액션
                    }) {
                        Image("shop")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Rank 탭
                    Button(action: {
                        // Rank 액션
                    }) {
                        Image("rank")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // My 탭
                    Button(action: {
                        // My 액션
                    }) {
                        Image("my")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 80.4)
                .background(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Color Extension (Hex)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
