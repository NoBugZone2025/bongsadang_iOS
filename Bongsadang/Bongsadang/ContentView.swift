import SwiftUI
import MapKit

struct VolunteerDetailView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: VolunteerLocation?
    
    // 봉사 참여 상태 및 타이머
    @State private var isParticipating: Bool = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // 봉사 시간 설정 (14:00 시작, 16:00 종료)
    let startTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 14
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()
    
    let endTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 16
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()
    
    var totalDuration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var progress: Double {
        min(elapsedTime / totalDuration, 1.0)
    }
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 배경 지도 (전체 화면)
            mapViewBackground
                .onTapGesture {
                    isSearchFocused = false
                    if !isParticipating {
                        selectedLocation = nil
                    }
                }
            
            // 상단 컨텐츠 레이어
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                topNavigationBar
                
                // 지역 검색 필드
                searchBar
                
                Spacer()
            }
            
            // 하단 카드
            if selectedLocation != nil || isParticipating {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 봉사 활동 카드 (상태에 따라 다르게 표시)
                    if isParticipating {
                        activeVolunteerCard
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                isSearchFocused = false
                            }
                    } else {
                        volunteerDetailCard
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                isSearchFocused = false
                            }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
                .transition(.move(edge: .bottom))
            }
            
            // 하단 탭 바
            bottomTabBar

            // 플로팅 액션 버튼 (탭바 위에 약간 걸치도록)
            VStack {
                Spacer()
                floatingActionButton
                    .offset(y: -42)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut, value: selectedLocation)
        .animation(.easeInOut, value: isParticipating)
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if elapsedTime < totalDuration {
                elapsedTime += 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startParticipation() {
        isParticipating = true
        selectedLocation = nil
        startTimer()
    }
    
    // MARK: - Components
    
    private var mapViewBackground: some View {
        Map(coordinateRegion: $region, annotationItems: volunteerLocations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Button(action: {
                    if !isParticipating {
                        selectedLocation = location
                    }
                }) {
                    mapMarker(number: location.id)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var topNavigationBar: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                
                Image("logoText")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 21)
            }
            
            Spacer()
            
            // 오른쪽 균형을 위한 투명 공간
            Color.clear
                .frame(width: 56)
        }
        .frame(height: 58)
        .background(Color.white)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 20)
            
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("원하는 지역을 입력하세요")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "828282"))
                        }
                        TextField("", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .focused($isSearchFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                isSearchFocused = false
                            }
                    }
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 20)
            }
            
            Spacer()
        }
        .frame(height: 44)
        .background(Color(hex: "FFF8DC"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "F5DEB3"), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .padding(.top, 9)
    }
    
    private func mapMarker(number: Int) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
            
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            if number == 3 {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .offset(x: 14, y: -14)
            }
        }
    }
    
    private var volunteerDetailCard: some View {
        VStack(spacing: 10) {
            // 상세 정보 카드
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("독거노인 도시락 배달")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Spacer()
                    
                    Text("2025.11.15")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "A0522D"))
                }
                
                HStack(alignment: .top) {
                    Text("따뜻한 마음으로 어르신들께\n도시락을 전달해요")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "A0522D"))
                        .lineSpacing(4)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("by 김봉사")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                        
                        Text("3/5")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "D2691E"))
                    }
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B4513"))
                        Text("서울시 강남구")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B4513"))
                        Text("14:00-16:00")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B4513"))
                        Text("1.2km")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                }
                .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "FFF7F0"))
            .cornerRadius(24)
            
            // 액션 버튼들
            HStack(spacing: 16) {
                Button(action: { selectedLocation = nil }) {
                    Text("돌아가기")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(28)
                }
                
                Button(action: { startParticipation() }) {
                    Text("참가하기")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private var activeVolunteerCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("독거노인 도시락 배달")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Spacer()
                    
                    Text("2025.11.15")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "A0522D"))
                }
                
                HStack(alignment: .top) {
                    Text("따뜻한 마음으로 어르신들께\n도시락을 전달해요")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "A0522D"))
                        .lineSpacing(4)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("by 김봉사")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                        
                        Text("3/5")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "D2691E"))
                    }
                }
                
                // 구분선
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 1)
                    .padding(.vertical, 8)
                
                // 타이머와 진행바
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Text(formattedTime)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 바
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 2)
                            
                            // 진행 바
                            Rectangle()
                                .fill(Color(hex: "FFD1A0"))
                                .frame(width: geometry.size.width * progress, height: 2)
                        }
                    }
                    .frame(height: 2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "FFF7F0"))
            .cornerRadius(24)
        }
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 10)
    }
    
    private var floatingActionButton: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "house", isSelected: false)
            tabBarItem(icon: "bag", isSelected: false)
            
            // 중앙 빈 공간 (플로팅 버튼을 위한)
            Spacer()
                .frame(width: 80)
            
            tabBarItem(icon: "chart.bar.fill", isSelected: false)
            tabBarItem(icon: "person", isSelected: false)
        }
        .frame(height: 84)
        .background(
            Color.white
                .overlay(
                    Color(hex: "FFF7F0").opacity(0.3)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
    
    private func tabBarItem(icon: String, isSelected: Bool) -> some View {
        Button(action: {}) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? Color(hex: "D2691E") : Color.gray.opacity(0.6))
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
    }
}

// MARK: - Supporting Types

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct VolunteerLocation: Identifiable, Equatable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
}

let volunteerLocations = [
    VolunteerLocation(id: 1, coordinate: CLLocationCoordinate2D(latitude: 37.5700, longitude: 126.9850)),
    VolunteerLocation(id: 2, coordinate: CLLocationCoordinate2D(latitude: 37.5650, longitude: 126.9750)),
    VolunteerLocation(id: 3, coordinate: CLLocationCoordinate2D(latitude: 37.5620, longitude: 126.9800)),
    VolunteerLocation(id: 8, coordinate: CLLocationCoordinate2D(latitude: 37.5640, longitude: 126.9820))
]

// MARK: - Color Extension

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
            (a, r, g, b) = (1, 1, 1, 0)
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

struct VolunteerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerDetailView()
    }
}
