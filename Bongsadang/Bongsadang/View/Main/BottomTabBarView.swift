import SwiftUI

struct BottomTabBarView: View {
    @Binding var showRankingModal: Bool
    @Binding var showMyPageModal: Bool

    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal = false
                }
            } label: {
                Image("home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity((!showRankingModal && !showMyPageModal) ? 1.0 : 0.5)
                    .frame(maxWidth: .infinity)
            }

            Button {
            
            } label: {
                Image("shop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity(0.5)
                    .frame(maxWidth: .infinity)
            }

            Spacer()
                .frame(width: 80)

            Button {
                withAnimation {
                    showMyPageModal = false
                    showRankingModal.toggle()
                }
            } label: {
                Image("rank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity(showRankingModal ? 1.0 : 0.5)
                    .frame(maxWidth: .infinity)
            }

            Button {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal.toggle()
                }
            } label: {
                Image("my")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity(showMyPageModal ? 1.0 : 0.5)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 84)
        .background(
            Color.white
        )
    }
}

