
import SwiftUI

struct MyPageBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var showLogoutAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MyProfileCardView(networkService: networkService)
                MyRecruitedVolunteersCardView(myVolunteers: networkService.myVolunteers)
                MyVolunteerRecordsCardView(completedVolunteers: networkService.completedVolunteers)

                // 로그아웃 버튼
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "FF3B30"))

                        Text("로그아웃")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "FF3B30"))

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
            }
            .padding(.top, 10)
        }
        .onAppear {
            Task {
                await networkService.loadCompletedVolunteers()
                await networkService.loadMyVolunteers()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                logout()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
    }

    private func logout() {
        // Keychain에서 토큰 삭제
        KeychainHelper.shared.delete(forKey: "accessToken")
        KeychainHelper.shared.delete(forKey: "refreshToken")

        // 로그인 상태 변경
        loginViewModel.isLoggedIn = false

        print("[MyPageBottomSheetView] 로그아웃 완료")
    }
}
