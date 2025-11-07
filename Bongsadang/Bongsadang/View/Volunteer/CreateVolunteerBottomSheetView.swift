
import SwiftUI
import CoreLocation
import Combine

struct CreateVolunteerBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService
    @ObservedObject var locationManager: LocationManager

    @Binding var showCreateVolunteerModal: Bool
    @State private var createTitle: String = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showLocationPicker: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600) // 1시간 후
    @State private var createParticipants: String = ""
    @State private var createContent: String = ""
    @State private var isPublicRecruitment: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                CreateFormSectionView(title: "제목") {
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

                        if selectedLocation == nil {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "A1A1A1"))
                                Text("현위치")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "A1A1A1"))
                            }
                        }
                    }
                    .padding(.horizontal, 19)

                    Button(action: {
                        showLocationPicker = true
                    }) {
                        HStack {
                            if let location = selectedLocation {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("선택된 위치")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color(hex: "8B4513"))
                                    Text("위도: \(String(format: "%.6f", location.latitude)), 경도: \(String(format: "%.6f", location.longitude))")
                                        .font(.system(size: 9))
                                        .foregroundColor(Color(hex: "A1A1A1"))
                                }
                            } else {
                                Text("위치 선택하기")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "A1A1A1"))
                            }

                            Spacer()

                            Image(systemName: "map.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "F6AD55"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 14)
                    }
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

                    VStack(spacing: 10) {
                        // 시작 시간
                        HStack {
                            Text("시작")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "8B4513"))
                                .frame(width: 35)

                            DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .font(.system(size: 10))
                                .accentColor(Color(hex: "F6AD55"))
                                .environment(\.locale, Locale(identifier: "ko_KR"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 37)
                        .background(Color.white)
                        .cornerRadius(16)

                        // 종료 시간
                        HStack {
                            Text("종료")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "8B4513"))
                                .frame(width: 35)

                            DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .font(.system(size: 10))
                                .accentColor(Color(hex: "F6AD55"))
                                .environment(\.locale, Locale(identifier: "ko_KR"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 37)
                        .background(Color.white)
                        .cornerRadius(16)
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
                            .foregroundColor(.black)
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

                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            showCreateVolunteerModal = false
                        }
                    }) {
                        Text("돌아가기")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#D6D6D6"))
                            .cornerRadius(16)
                    }

                    Button(action: {
                        submitVolunteerCreation()
                    }) {
                        Text("모집하기")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Color(hex: "#F6AD55")
                            )
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 15)
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
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(
                locationManager: locationManager,
                selectedLocation: $selectedLocation
            )
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

        // DatePicker에서 선택된 날짜/시간 사용
        guard startDate < endDate else {
            networkService.errorMessage = "종료 시간은 시작 시간 이후여야 합니다."
            return
        }

        // 선택된 위치가 있으면 그 값을 사용하고, 없으면 현재 위치 사용
        let finalLocation: CLLocationCoordinate2D
        if let selected = selectedLocation {
            finalLocation = selected
        } else {
            guard let userLocation = locationManager.userLocation else {
                networkService.errorMessage = "위치 정보를 가져올 수 없습니다."
                return
            }
            finalLocation = userLocation.coordinate
        }

        let request = CreateVolunteerRequest(
            title: createTitle,
            description: createContent,
            latitude: finalLocation.latitude,
            longitude: finalLocation.longitude,
            startDateTime: startDate.toISO8601String(),
            endDateTime: endDate.toISO8601String(),
            maxParticipants: maxParticipants,
            visibilityType: isPublicRecruitment ? "PUBLIC" : "PRIVATE",
            volunteerType: "OTHER"
        )

        Task {
            let success = await networkService.createAndLoadVolunteer(request: request)

            if success {
                await MainActor.run {
                    withAnimation {
                        showCreateVolunteerModal = false
                        createTitle = ""
                        selectedLocation = nil
                        startDate = Date()
                        endDate = Date().addingTimeInterval(3600)
                        createParticipants = ""
                        createContent = ""
                        isPublicRecruitment = false
                    }
                }
            }
        }
    }
}
