
import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @State private var region: MKCoordinateRegion
    @State private var pinLocation: CLLocationCoordinate2D?

    init(locationManager: LocationManager, selectedLocation: Binding<CLLocationCoordinate2D?>) {
        self._locationManager = ObservedObject(wrappedValue: locationManager)
        self._selectedLocation = selectedLocation

        // 현재 위치가 있으면 사용하고, 없으면 서울을 기본값으로
        let initialCoordinate = locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        self._region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        self._pinLocation = State(initialValue: locationManager.userLocation?.coordinate)
    }

    var body: some View {
        ZStack {
            // 지도
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: pinLocation.map { [MapPin(coordinate: $0)] } ?? []) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                }
            }
            .onTapGesture { location in
                // 화면 좌표를 지도 좌표로 변환하는 간단한 방법
                // 중앙 위치를 핀 위치로 설정
                pinLocation = region.center
            }

            // 위치 권한이 없을 때 표시되는 오버레이
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                VStack(spacing: 20) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "F6AD55"))

                    Text("위치 권한이 필요합니다")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    Text("설정에서 위치 권한을 허용해주세요")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        Text("설정으로 이동")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color(hex: "F6AD55"))
                            .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.95))
            }

            // 중앙 십자선
            VStack {
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.gray.opacity(0.5))
                Spacer()
            }
            .allowsHitTesting(false)

            // 상단 안내 텍스트
            VStack {
                Text("지도를 움직여서 위치를 선택하세요")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.top, 60)

                Spacer()
            }

            // 하단 버튼들
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("취소")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }

                    Button(action: {
                        selectedLocation = region.center
                        dismiss()
                    }) {
                        Text("이 위치로 선택")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#F6AD55"))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 뷰가 나타날 때 현재 위치로 지도 이동
            if let currentLocation = locationManager.userLocation?.coordinate {
                region.center = currentLocation
                pinLocation = currentLocation
            }
        }
        .onChange(of: region.center) { newCenter in
            pinLocation = newCenter
        }
    }
}

// Map Annotation을 위한 간단한 구조체
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
