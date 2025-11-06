
import SwiftUI

struct MyPageBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MyProfileCardView(networkService: networkService)
                MyRecruitedVolunteersCardView(myVolunteers: networkService.myVolunteers)
                MyVolunteerRecordsCardView(completedVolunteers: networkService.completedVolunteers)
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
    }
}
