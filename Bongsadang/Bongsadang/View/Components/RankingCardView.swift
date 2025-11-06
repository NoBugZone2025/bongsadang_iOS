
import SwiftUI

struct RankingCardView: View {
    let user: RankingUser

    var body: some View {
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
}
