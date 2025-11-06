
import SwiftUI

struct MyProfileCardView: View {
    @ObservedObject var networkService: VolunteerNetworkService

    var body: some View {
        HStack(spacing: 12) {
            Text("\(networkService.userInfo?.rank ?? 0).")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(getRankColor(networkService.userInfo?.rank ?? 0))
                .frame(width: 40, alignment: .leading)

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(networkService.userInfo?.role ?? "역할")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "8B4513"))

                Text(networkService.userInfo?.name ?? "사용자")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "8B4513"))

                Text(networkService.userInfo?.email ?? "이메일")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "8B4513"))
            }

            Spacer()

            Text(networkService.userInfo?.formattedPoints ?? "0P")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }

    // 랭크 색상 반환 헬퍼 함수 추가
    private func getRankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return .gold
        case 2:
            return .silver
        case 3:
            return .bronze
        default:
            return .black
        }
    }
}
