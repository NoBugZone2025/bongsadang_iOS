import SwiftUI
import MapKit
import CoreLocation
import Combine

struct VolunteerDetailView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: VolunteerLocation?
    @StateObject private var locationManager = LocationManager()
    @State private var isParticipating: Bool = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showRankingModal: Bool = false
    
    let startTime: Date = Date()
    
    let endTime: Date = {
        return Date().addingTimeInterval(5)
    }()
    
    var totalDuration: TimeInterval {
        5
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

    var volunteerLocations: [VolunteerLocation] {
        guard let userLat = locationManager.userLocation?.coordinate.latitude,
              let userLon = locationManager.userLocation?.coordinate.longitude else {
            return []
        }

        return [
            VolunteerLocation(id: 1, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.008, longitude: userLon + 0.012)),
            VolunteerLocation(id: 2, coordinate: CLLocationCoordinate2D(latitude: userLat - 0.005, longitude: userLon - 0.008)),
            VolunteerLocation(id: 3, coordinate: CLLocationCoordinate2D(latitude: userLat - 0.010, longitude: userLon + 0.005)),
            VolunteerLocation(id: 4, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.003, longitude: userLon - 0.010)),
            VolunteerLocation(id: 5, coordinate: CLLocationCoordinate2D(latitude: userLat - 0.002, longitude: userLon + 0.015)),
            VolunteerLocation(id: 6, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.012, longitude: userLon + 0.003)),
            VolunteerLocation(id: 7, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.001, longitude: userLon - 0.006)),
            VolunteerLocation(id: 8, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.006, longitude: userLon + 0.008)),
            VolunteerLocation(id: 9, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.015, longitude: userLon - 0.004)),
            VolunteerLocation(id: 10, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.004, longitude: userLon + 0.002)),
            VolunteerLocation(id: 11, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.010, longitude: userLon + 0.010)),
            VolunteerLocation(id: 12, coordinate: CLLocationCoordinate2D(latitude: userLat + 0.018, longitude: userLon - 0.002))
        ]
    }
    
    let rankings: [RankingUser] = [
        RankingUser(rank: 1, username: "User1", location: "서울시 은평구", points: "1558P", title: "칭호", rankColor: .gold),
        RankingUser(rank: 2, username: "User2", location: "서울시 은평구", points: "1557P", title: "칭호", rankColor: .silver),
        RankingUser(rank: 3, username: "User3", location: "서울시 은평구", points: "1556P", title: "칭호", rankColor: .bronze),
        RankingUser(rank: 4, username: "User4", location: "서울시 은평구", points: "1555P", title: "칭호", rankColor: .black),
        RankingUser(rank: 5, username: "User5", location: "서울시 은평구", points: "334P", title: "칭호", rankColor: .black),
        RankingUser(rank: 6, username: "User41", location: "서울시 은평구", points: "228P", title: "칭호", rankColor: .black),
        RankingUser(rank: 7, username: "User4", location: "서울시 은평구", points: "1555P", title: "칭호", rankColor: .black)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mapViewBackground
                .onTapGesture {
                    isSearchFocused = false
                    if !isParticipating {
                        selectedLocation = nil
                    }
                }
            VStack(spacing: 0) {
                topNavigationBar
                searchBar
                if isParticipating {
                    activeVolunteerCard
                        .padding(.horizontal, 10)
                        .padding(.top, 13)
                        .onTapGesture {
                            isSearchFocused = false
                        }
                }
                
                Spacer()
            }
            if selectedLocation != nil && !isParticipating {
                VStack(spacing: 0) {
                    Spacer()
                    
                    volunteerDetailCard
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            isSearchFocused = false
                        }
                    
                    Spacer()
                        .frame(height: 100)
                }
                .transition(.move(edge: .bottom))
            }
            
            // Ranking Bottom Sheet
            if showRankingModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9) // topNav + searchBar + spacing
                    
                    rankingBottomSheet
                        .padding(.horizontal, 10)
                        .padding(.bottom, 97) // 84 (tabBar) + 13 (spacing above tabBar)
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showRankingModal = false
                            }
                        }
                )
                .transition(.opacity)
            }
            
            bottomTabBar
            VStack {
                Spacer()
                floatingActionButton
                    .offset(y: -42)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut, value: selectedLocation)
        .animation(.easeInOut, value: isParticipating)
        .animation(.easeInOut, value: showRankingModal)
        .onAppear {
            centerMapOnUserLocation()
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let location = newLocation {
                withAnimation {
                    region.center = location.coordinate
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    private func centerMapOnUserLocation() {
        locationManager.requestLocation()
        if let location = locationManager.userLocation {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
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
    
    private var mapViewBackground: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: volunteerLocations) { location in
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
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("독거노인 도시락 배달")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Spacer()
                    
                    Text("2025.11.15")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "A0522D"))
                }
                
                HStack(alignment: .top) {
                    Text("따뜻한 마음으로 어르신들께\n도시락을 전달해요")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "A0522D"))
                        .lineSpacing(2)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("by 김봉사")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0522D"))
                        
                        Text("3/5")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "D2691E"))
                    }
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 1)
                    .padding(.vertical, 4)
                VStack(spacing: 6) {
                    HStack {
                        Spacer()
                        Text(formattedTime)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 2)
                            Rectangle()
                                .fill(Color(hex: "FFD1A0"))
                                .frame(width: geometry.size.width * progress, height: 2)
                        }
                    }
                    .frame(height: 2)
                }
                if elapsedTime >= totalDuration {
                    HStack {
                        Spacer()
                        Button(action: {
                        }) {
                            Text("인증하기")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 33.14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16.57)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "FFF7F0"))
            .cornerRadius(24)
        }
        .frame(height: 200)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
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
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "house", isSelected: false)
            tabBarItem(icon: "bag", isSelected: false)
            Spacer()
                .frame(width: 80)
            tabBarItem(icon: "chart.bar.fill", isSelected: showRankingModal, action: {
                withAnimation {
                    showRankingModal.toggle()
                }
            })
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

    private func tabBarItem(icon: String, isSelected: Bool, action: (() -> Void)? = nil) -> some View {
        Button(action: {
            action?()
        }) {
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
    
    // MARK: - Ranking Bottom Sheet
    private var rankingBottomSheet: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(rankings) { user in
                    rankingCard(user: user)
                }
            }
            .padding(.top, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private func rankingCard(user: RankingUser) -> some View {
        HStack(spacing: 12) {
            // Rank Number
            Text("\(user.rank).")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(user.rankColor)
                .frame(width: 40, alignment: .leading)
            
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(user.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text(user.title)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Color(hex: "8B4513"))
                }
                
                Text(user.location)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "8B4513"))
            }
            
            Spacer()
            
            // Points
            Text(user.points)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
}

// MARK: - Models
struct RankingUser: Identifiable {
    let id = UUID()
    let rank: Int
    let username: String
    let location: String
    let points: String
    let title: String
    let rankColor: Color
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct VolunteerLocation: Identifiable, Equatable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
}

extension Color {
    static let gold = Color(hex: "FFCE1B")
    static let silver = Color(hex: "C5C5C5")
    static let bronze = Color(hex: "B25F00")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

struct VolunteerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerDetailView()
    }
}
