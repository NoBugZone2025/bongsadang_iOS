
import SwiftUI

struct RankingBottomSheetView: View {
    @ObservedObject var networkService: VolunteerNetworkService

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(networkService.rankings) { user in
                    RankingCardView(user: user)
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
}
