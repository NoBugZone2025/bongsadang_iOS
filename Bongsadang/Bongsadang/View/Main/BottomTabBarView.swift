
import SwiftUI

struct BottomTabBarView: View {
    @Binding var showRankingModal: Bool
    @Binding var showMyPageModal: Bool

    var body: some View {
        HStack(spacing: 0) {
            TabBarItemView(icon: "house", isSelected: !showRankingModal && !showMyPageModal, action: {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal = false
                }
            })
            TabBarItemView(icon: "bag", isSelected: false, action: nil)
            Spacer()
                .frame(width: 80)
            TabBarItemView(icon: "chart.bar.fill", isSelected: showRankingModal, action: {
                withAnimation {
                    showMyPageModal = false
                    showRankingModal.toggle()
                }
            })
            TabBarItemView(icon: "person", isSelected: showMyPageModal, action: {
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
}
