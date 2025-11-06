
import SwiftUI
import CoreLocation
import Combine

struct CreateVolunteerBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService
    @ObservedObject var locationManager: LocationManager

    @Binding var showCreateVolunteerModal: Bool
    @State private var createTitle: String = ""
    @State private var createLocation: String = ""
    @State private var createStartTime: String = ""
    @State private var createEndTime: String = ""
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
            volunteerType: "OTHER"
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
}
