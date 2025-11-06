
import SwiftUI

struct FriendsManagementCardView: View {
    var body: some View {
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
}
