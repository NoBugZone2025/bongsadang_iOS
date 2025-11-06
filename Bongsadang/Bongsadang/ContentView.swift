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
    @State private var createTitle: String = ""
    @State private var createLocation: String = ""
    @State private var createStartTime: String = ""
    @State private var createEndTime: String = ""
    @State private var createParticipants: String = ""
    @State private var createContent: String = ""
    @State private var isPublicRecruitment: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var showRecenterButton: Bool = false
    @State private var isMapDragging: Bool = false
    
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
            
            if showRankingModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9)
                    
                    rankingBottomSheet
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
                    
                    myPageBottomSheet
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
                
                verificationCompleteModal
            }
            
            if showCreateVolunteerModal {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 58 + 44 + 9 + 9)
                    
                    createVolunteerBottomSheet
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
    
    private func submitVolunteerCreation() {
        guard !createTitle.isEmpty else {
            networkService.errorMessage = "제목을 입력해주세요."
            return
        }
        
        guard !createContent.isEmpty else {
            networkService.errorMessage = "내용을 입력해주세요."
            return
        }
        
        guard !createParticipants.isEmpty, let maxParticipants = Int(createParticipants) else {
            networkService.errorMessage = "올바른 모집 인원을 입력해주세요."
            return
        }
        
        guard !createStartTime.isEmpty, !createEndTime.isEmpty else {
            networkService.errorMessage = "시작 시간과 종료 시간을 입력해주세요."
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTime = dateFormatter.date(from: createStartTime),
              let endTime = dateFormatter.date(from: createEndTime) else {
            networkService.errorMessage = "시간 형식이 올바르지 않습니다. (예: 14:00)"
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        startComponents.hour = startTimeComponents.hour
        startComponents.minute = startTimeComponents.minute
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        endComponents.hour = endTimeComponents.hour
        endComponents.minute = endTimeComponents.minute
        
        guard let startDateTime = calendar.date(from: startComponents),
              let endDateTime = calendar.date(from: endComponents) else {
            networkService.errorMessage = "날짜 생성 중 오류가 발생했습니다."
            return
        }
        
        guard let userLocation = locationManager.userLocation else {
            networkService.errorMessage = "위치 정보를 가져올 수 없습니다."
            return
        }
        
        let request = CreateVolunteerRequest(
            title: createTitle,
            description: createContent,
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude,
            startDateTime: startDateTime.toISO8601String(),
            endDateTime: endDateTime.toISO8601String(),
            maxParticipants: maxParticipants,
            visibilityType: isPublicRecruitment ? "PUBLIC" : "PRIVATE",
            volunteerType: "GENERAL"
        )
        
        Task {
            let success = await networkService.createAndLoadVolunteer(request: request)
            
            if success {
                await MainActor.run {
                    withAnimation {
                        showCreateVolunteerModal = false
                        createTitle = ""
                        createLocation = ""
                        createStartTime = ""
                        createEndTime = ""
                        createParticipants = ""
                        createContent = ""
                        isPublicRecruitment = false
                    }
                }
            }
        }
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
                    mapMarker(number: location.volunteerData.maxParticipants)
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
        }
    }
    private var volunteerDetailCard: some View {
        VStack(spacing: 10) {
            if let location = selectedLocation {
                let volunteer = location.volunteerData
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(volunteer.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))
                        
                        Spacer()
                        
                        Text(volunteer.formattedStartDate)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                    
                    HStack(alignment: .top) {
                        Text(volunteer.description)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(4)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("by \(volunteer.organizerName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                            
                            Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "D2691E"))
                        }
                    }
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(getLocationText(volunteer))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(volunteer.formattedTimeRange)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(getDistanceText(volunteer))
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
            }
            
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
    
    private func getLocationText(_ volunteer: VolunteerData) -> String {
        return "위도: \(String(format: "%.2f", volunteer.latitude))"
    }
    
    private func getDistanceText(_ volunteer: VolunteerData) -> String {
        let centerLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let volunteerLocation = CLLocation(latitude: volunteer.latitude, longitude: volunteer.longitude)
        let distance = centerLocation.distance(from: volunteerLocation)
        
        if distance < 1000 {
            return String(format: "%.0fm", distance)
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    private var activeVolunteerCard: some View {
        VStack(spacing: 0) {
            if let volunteer = currentParticipatingVolunteer {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(volunteer.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))
                        
                        Spacer()
                        
                        Text(volunteer.formattedStartDate)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                    
                    HStack(alignment: .top) {
                        Text(volunteer.description)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(2)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("by \(volunteer.organizerName)")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "A0522D"))
                            
                            Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
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
                                showImagePicker = true
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
        Button(action: {
            withAnimation {
                showCreateVolunteerModal.toggle()
            }
        }) {
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
            tabBarItem(icon: "house", isSelected: !showRankingModal && !showMyPageModal, action: {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal = false
                }
            })
            tabBarItem(icon: "bag", isSelected: false)
            Spacer()
                .frame(width: 80)
            tabBarItem(icon: "chart.bar.fill", isSelected: showRankingModal, action: {
                withAnimation {
                    showMyPageModal = false
                    showRankingModal.toggle()
                }
            })
            tabBarItem(icon: "person", isSelected: showMyPageModal, action: {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal.toggle()
                }
            })
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
    
    private var rankingBottomSheet: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(networkService.rankings) { user in
                    rankingCard(user: user)
                }
                
                if networkService.rankings.isEmpty && !networkService.isLoading {
                    Text("랭킹 데이터가 없습니다")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
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
            Text("\(user.rank).")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(user.rankColor)
                .frame(width: 40, alignment: .leading)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(user.userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text(user.currentTitle ?? "")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Color(hex: "8B4513"))
                }
            }
            
            Spacer()
            
            Text(user.formattedPoints)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
    
    private var myPageBottomSheet: some View {
        ScrollView {
            VStack(spacing: 10) {
                myProfileCard
                friendsManagementCard
                myVolunteerRecordsCard
            }
            .padding(.top, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private var myProfileCard: some View {
        HStack(spacing: 12) {
            Text("22.")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 40, alignment: .leading)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("UserK")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                    
                    Text("칭호")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Color(hex: "8B4513"))
                }
                
                Text("서울시 은평구")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "8B4513"))
            }
            
            Spacer()
            
            Text("223P")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
    
    private var friendsManagementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("친구 관리")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.leading, 19)
            
            HStack(spacing: 21) {
                ForEach(0..<5) { index in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                            )
                        
                        Text("User1")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                }
            }
            .padding(.horizontal, 19)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
    
    private var myVolunteerRecordsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("나의 봉사 기록")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.horizontal, 19)
            
            VStack(spacing: 12) {
                volunteerRecordItem(
                    title: "독거노인 도시락 배달",
                    description: "따뜻한 마음으로 어르신들께\n도시락을 전달해요",
                    date: "2025.11.15",
                    organizer: "by 김봉사",
                    participants: "3/5",
                    location: "서울시 강남구",
                    time: "14:00-16:00",
                    distance: "1.2km"
                )
                
                volunteerRecordItem(
                    title: "바닷가 쓰레기 줍기",
                    description: "줍깅",
                    date: "2025.12.02",
                    organizer: "by 이봉창",
                    participants: "2/2",
                    location: "부산시 수영구",
                    time: "11:00-13:00",
                    distance: "334km"
                )
            }
            .padding(.horizontal, 19)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
    
    private func volunteerRecordItem(
        title: String,
        description: String,
        date: String,
        organizer: String,
        participants: String,
        location: String,
        time: String,
        distance: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "8B4513"))
                
                Spacer()
                
                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "A0522D"))
            }
            
            HStack(alignment: .top) {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "A0522D"))
                    .lineSpacing(3)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(organizer)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                    
                    Text(participants)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "D2691E"))
                }
            }
            
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(location)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(time)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(distance)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }
            }
        }
        .padding(17)
        .background(Color.white)
        .cornerRadius(22)
    }
    
    private var createVolunteerBottomSheet: some View {
        ScrollView {
            VStack(spacing: 10) {
                createFormSection(title: "제목") {
                    TextField("", text: $createTitle)
                        .placeholder(when: createTitle.isEmpty, placeholder: {
                            Text("제목을 입력하세요...")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                        })
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .frame(height: 37)
                        .background(Color.white)
                        .cornerRadius(16)
                        .focused($isTextFieldFocused)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("위치")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                            Text("현위치")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                        }
                    }
                    .padding(.horizontal, 19)
                    
                    TextField("", text: $createLocation)
                        .placeholder(when: createLocation.isEmpty, placeholder: {
                            Text("서울특별시 종로구 XXX")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                        })
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .frame(height: 37)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 14)
                        .focused($isTextFieldFocused)
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
                .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("일정 및 모집인원")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                        .padding(.horizontal, 19)
                    
                    HStack(spacing: 19) {
                        TextField("", text: $createStartTime)
                            .placeholder(when: createStartTime.isEmpty, placeholder: {
                                Text("시작 시간 (14:00)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "A1A1A1"))
                            })
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .frame(height: 37)
                            .background(Color.white)
                            .cornerRadius(16)
                            .focused($isTextFieldFocused)
                        
                        TextField("", text: $createEndTime)
                            .placeholder(when: createEndTime.isEmpty, placeholder: {
                                Text("종료 시간 (16:00)")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "A1A1A1"))
                            })
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .frame(height: 37)
                            .background(Color.white)
                            .cornerRadius(16)
                            .focused($isTextFieldFocused)
                    }
                    .padding(.horizontal, 10)
                    
                    TextField("", text: $createParticipants)
                        .placeholder(when: createParticipants.isEmpty, placeholder: {
                            Text("모집 인원")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                        })
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .frame(height: 37)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 10)
                        .focused($isTextFieldFocused)
                        .keyboardType(.numberPad)
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
                .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("내용")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "8B4513"))
                        .padding(.horizontal, 19)
                    
                    ZStack(alignment: .topLeading) {
                        if createContent.isEmpty {
                            Text("내용을 입력하세요...")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "A1A1A1"))
                                .padding(.horizontal, 16)
                                .padding(.top, 11)
                        }
                        
                        TextEditor(text: $createContent)
                            .font(.system(size: 10))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(height: 106)
                            .background(Color.white)
                            .cornerRadius(16)
                            .scrollContentBackground(.hidden)
                            .focused($isTextFieldFocused)
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
                .padding(.horizontal, 10)
                
                Toggle(isOn: $isPublicRecruitment) {
                    Text("공개 모집")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A1A1A1"))
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "D2691E")))
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 30) {
                    Button(action: {
                        withAnimation {
                            showCreateVolunteerModal = false
                        }
                    }) {
                        Text("돌아가기")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "A1A1A1"))
                            .cornerRadius(28)
                    }
                    
                    Button(action: {
                        submitVolunteerCreation()
                    }) {
                        Text("모집하기")
                            .font(.system(size: 16))
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
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            .padding(.top, 10)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private func createFormSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.horizontal, 19)
            
            content()
                .padding(.horizontal, 14)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
    
    private var verificationCompleteModal: some View {
        VStack(spacing: 0) {
            if let volunteer = currentParticipatingVolunteer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(volunteer.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))
                        
                        Spacer()
                        
                        Text(volunteer.formattedStartDate)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0522D"))
                    }
                    
                    HStack(alignment: .top) {
                        Text(volunteer.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(3)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("by \(volunteer.organizerName)")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "A0522D"))
                            
                            Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "D2691E"))
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .padding(.vertical, 4)
                    
                    HStack {
                        Spacer()
                        Text(formattedTime)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8B4513"))
                    }
                    
                    Rectangle()
                        .fill(Color(hex: "FFD1A0"))
                        .frame(height: 2)
                    
                    VStack(spacing: 10) {
                        Text("인증 완료!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "D2691E"))
                        
                        Text("445P 지급!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "D2691E"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .cornerRadius(22)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
            }
            
            Button(action: {
                withAnimation {
                    showVerificationComplete = false
                    isParticipating = false
                    currentParticipatingVolunteer = nil
                    elapsedTime = 0
                }
            }) {
                Text("확인")
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
            .padding(.top, 10)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 100)
    }
}

// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "D2691E")))
                
                Text("봉사활동을 불러오는 중...")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
            )
        }
    }
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.onImageSelected()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageSelected()
        }
    }
}