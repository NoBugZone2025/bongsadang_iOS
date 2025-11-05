import SwiftUI
import

struct MapboxView: UIViewRepresentable {
    private let token = "pk.eyJ1IjoiYm9uZ3NhZGFuZyIsImEiOiJjbWhseGtwMmQwNzZkMmlzamFsdjBjZDAxIn0.5aIJJjz8ct1f5HCSRlBN7Q"
    private let styleURL = "mapbox://styles/bongsadang/cmhlxqa1d00k101si5frs0lkb"

    func makeUIView(context: Context) -> MapView {
        let resourceOptions = ResourceOptions(accessToken: token)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,
                                            styleURI: StyleURI(url: styleURL))

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
        // 초기 카메라 위치 (서울 시청 근처)
        let camera = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
                                   zoom: 11)
        mapView.mapboxMap.setCamera(to: camera)
        
        return mapView
    }

    func updateUIView(_ uiView: MapView, context: Context) {
        // SwiftUI에서 상태가 바뀔 때 지도에 변화 줄 수 있음
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            MapboxView()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("봉사당 지도")
                    .font(.headline)
                    .padding(8)
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
