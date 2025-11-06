import SwiftUI
import MapKit
import CoreLocation
import Combine

struct VolunteerDetailView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var searchText: String = "";
    @FocusState private var isSearchFocused: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: VolunteerLocation?
    @State private var currentParticipatingVolunteer: VolunteerData?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var networkService = VolunteerNetworkService.shared
    @State private var volunteerLocations: [VolunteerLocation] = []
    @State private var isParticipating: Bool = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showRankingModal: Bool = false
    @State private var showMyPageModal: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var showVerificationComplete: Bool = false
    @State private var showCreateVolunteerModal: Bool = false

    @State private var showRecenterButton: Bool = false
    @State private var isMapDragging: Bool = false

    // 검색 결과
    var filteredVolunteers: [VolunteerData] {
        if searchText.isEmpty {
            return []
        }
        return networkService.volunteers.filter { volunteer in
            volunteer.title.localizedCaseInsensitiveContains(searchText) ||
            volunteer.description.localizedCaseInsensitiveContains(searchText) ||
            volunteer.organizerName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(region: $region, volunteerLocations: $volunteerLocations, selectedLocation: $selectedLocation, isParticipating: $isParticipating)
                .onTapGesture {
                    isSearchFocused = false
                    if !isParticipating {
                        selectedLocation = nil
                    }
                }
            
            VStack(spacing: 0) {
                TopNavigationBar()
                SearchBarView(searchText: $searchText, isSearchFocused: $isSearchFocused)

                // 검색 결과 리스트
                if !searchText.isEmpty && !filteredVolunteers.isEmpty {
                    SearchResultsListView(
                        volunteers: filteredVolunteers,
                        onSelectVolunteer: { volunteer in
                            selectVolunteerFromSearch(volunteer)
                        }
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 9)
                }

                if isParticipating {
                    ActiveVolunteerCardView(currentParticipatingVolunteer: $currentParticipatingVolunteer, elapsedTime: $elapsedTime, totalDuration: totalDuration, showImagePicker: $showImagePicker)
                        .padding(.horizontal, 10)
                        .padding(.top, 13)
                        .onTapGesture {
                            isSearchFocused = false
                        }
                }

                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            searchCurrentMapCenter()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .medium))
                                Text("이 지역 검색")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        
                        if showRecenterButton {
                            Button(action: {
                                centerMapOnUserLocation()
                                withAnimation {
                                    showRecenterButton = false
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color(hex: "8B4513"))
                                    .cornerRadius(28)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, isParticipating ? 350 : 120)
                
                Spacer()
            }
            
            if selectedLocation != nil && !isParticipating {
                VStack(spacing: 0) {
                    Spacer()
                    
                    VolunteerDetailCardView(selectedLocation: $selectedLocation, region: region, startParticipation: startParticipation)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            isSearchFocused = false
                        }
                    
                    Spacer()
                        .frame(height: 100)
                }
                .transition(.move(edge: .bottom))
            }
            
            if showRankingModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9)
                    
                    RankingBottomSheetView(networkService: networkService)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 97)
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
            
            if showMyPageModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9)

                    MyPageBottomSheetView(networkService: networkService, loginViewModel: loginViewModel)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 97)
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMyPageModal = false
                            }
                        }
                )
                .transition(.opacity)
            }
            
            if showVerificationComplete {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VerificationCompleteModal(showVerificationComplete: $showVerificationComplete, isParticipating: $isParticipating, currentParticipatingVolunteer: $currentParticipatingVolunteer, elapsedTime: $elapsedTime, formattedTime: formattedTime)
            }
            
            if showCreateVolunteerModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9)
                    
                    CreateVolunteerBottomSheetView(networkService: networkService, locationManager: locationManager, showCreateVolunteerModal: $showCreateVolunteerModal)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 97)
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showCreateVolunteerModal = false
                            }
                        }
                )
                .transition(.opacity)
            }
            
            if networkService.isLoading {
                LoadingView()
            }
            
            BottomTabBarView(showRankingModal: $showRankingModal, showMyPageModal: $showMyPageModal)
            VStack {
                Spacer()
                FloatingActionButton(showCreateVolunteerModal: $showCreateVolunteerModal)
                    .offset(y: -42)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut, value: selectedLocation)
        .animation(.easeInOut, value: isParticipating)
        .animation(.easeInOut, value: showRankingModal)
        .animation(.easeInOut, value: showMyPageModal)
        .animation(.easeInOut, value: showVerificationComplete)
        .animation(.easeInOut, value: showCreateVolunteerModal)
        .animation(.easeInOut, value: showRecenterButton)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, onImageSelected: {
                showImagePicker = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showVerificationComplete = true
                    }
                }
            })
        }
        .alert("오류", isPresented: .constant(networkService.errorMessage != nil), actions: {
            Button("확인") {
                networkService.errorMessage = nil
            }
        }, message: {
            Text(networkService.errorMessage ?? "")
        })
        .onAppear {
            centerMapOnUserLocation()
            loadVolunteersAtCurrentLocation()
            checkParticipatingVolunteer()
        }
        .onChange(of: region.center) { newCenter in
            checkIfMapMovedFromUserLocation(newCenter)
        }
        .onChange(of: networkService.volunteers) { volunteers in
            updateVolunteerLocations(volunteers)
        }
        .onChange(of: showRankingModal) { newValue in
            if newValue {
                Task {
                    await networkService.loadRankings()
                }
            }
        }
        .onChange(of: showMyPageModal) { newValue in
            if newValue {
                Task {
                    await networkService.loadUserInfo()
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func checkIfMapMovedFromUserLocation(_ newCenter: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.userLocation else { return }
        
        let distance = CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)
            .distance(from: userLocation)
        
        withAnimation {
            showRecenterButton = distance > 100
        }
    }
    
    private func searchCurrentMapCenter() {
        let center = region.center
        print("🔍 Searching at map center: lat=\(center.latitude), lon=\(center.longitude)")
        
        Task {
            await networkService.loadNearbyVolunteers(
                latitude: center.latitude,
                longitude: center.longitude,
                radiusKm: 10.0
            )
        }
    }
    
    private func centerMapOnUserLocation() {
        locationManager.requestLocation()
        if let location = locationManager.userLocation {
            withAnimation {
                region.center = location.coordinate
            }
            loadVolunteersAtCurrentLocation()
        }
    }
    
    private func loadVolunteersAtCurrentLocation() {
        guard let userLocation = locationManager.userLocation else {
            print("⚠️ User location not available yet")
            return
        }
        
        Task {
            await networkService.loadNearbyVolunteers(
                latitude: userLocation.coordinate.latitude,
                longitude: userLocation.coordinate.longitude,
                radiusKm: 10.0
            )
        }
    }
    
    private func updateVolunteerLocations(_ volunteers: [VolunteerData]) {
        var coordinateGroups: [String: [VolunteerData]] = [:]
        
        for volunteer in volunteers {
            let key = "\(volunteer.latitude),\(volunteer.longitude)"
            if coordinateGroups[key] == nil {
                coordinateGroups[key] = []
            }
            coordinateGroups[key]?.append(volunteer)
        }
        
        volunteerLocations = volunteers.enumerated().map {
            index, volunteer in
            let key = "\(volunteer.latitude),\(volunteer.longitude)"
            let group = coordinateGroups[key] ?? []
            
            if group.count > 1, let groupIndex = group.firstIndex(where: { $0.id == volunteer.id }) {
                let offset = Double(groupIndex) * 0.0001
                let adjustedCoordinate = CLLocationCoordinate2D(
                    latitude: volunteer.latitude + offset,
                    longitude: volunteer.longitude + offset
                )
                return VolunteerLocation(
                    id: volunteer.id,
                    coordinate: adjustedCoordinate,
                    volunteerData: volunteer
                )
            } else {
                return VolunteerLocation(
                    id: volunteer.id,
                    coordinate: volunteer.coordinate,
                    volunteerData: volunteer
                )
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
        guard let location = selectedLocation else { return }

        Task {
            let volunteer = await networkService.participateAndStartActivity(volunteerId: location.id)

            if let volunteer = volunteer {
                await MainActor.run {
                    currentParticipatingVolunteer = volunteer
                    isParticipating = true
                    selectedLocation = nil
                    startTimer()
                }
            }
        }
    }

    private func checkParticipatingVolunteer() {
        Task {
            do {
                if let participating = try await networkService.fetchParticipatingVolunteer() {
                    // verified가 true인 경우만 진행 중으로 처리
                    if participating.verified == true {
                        await MainActor.run {
                            currentParticipatingVolunteer = participating
                            isParticipating = true

                            // 시작 시간부터 현재까지의 경과 시간 계산
                            if let startDate = parseDateTime(participating.startDateTime) {
                                elapsedTime = Date().timeIntervalSince(startDate)
                            }

                            startTimer()
                            print("✅ Resumed participating volunteer: \(participating.title)")
                        }
                    }
                }
            } catch {
                print("🔴 Failed to check participating volunteer: \(error)")
            }
        }
    }

    private func parseDateTime(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        return formatter.date(from: dateString)
    }

    private func selectVolunteerFromSearch(_ volunteer: VolunteerData) {
        // 검색어 초기화 및 포커스 해제
        searchText = ""
        isSearchFocused = false

        // 지도 중심을 해당 봉사활동 위치로 이동
        withAnimation {
            region.center = volunteer.coordinate
        }

        // 해당 위치의 VolunteerLocation 찾기
        if let location = volunteerLocations.first(where: { $0.volunteerData.id == volunteer.id }) {
            selectedLocation = location
        }
    }

}

