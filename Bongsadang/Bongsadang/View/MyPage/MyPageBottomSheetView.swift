
import SwiftUI

struct MyPageBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MyProfileCardView(networkService: networkService)
                MyVolunteerRecordsCardView()
            }
            .padding(.top, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
}
