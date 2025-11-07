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
                VStack(spacing: 4) {
                    Image("home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    if !showRankingModal && !showMyPageModal {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Button {

            } label: {
                VStack(spacing: 4) {
                    Image("shop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
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
                VStack(spacing: 4) {
                    Image("rank")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    if showRankingModal {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                withAnimation {
                    showRankingModal = false
                    showMyPageModal.toggle()
                }
            } label: {
                VStack(spacing: 4) {
                    Image("my")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    if showMyPageModal {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 84)
        .background(
            Color.white
        )
    }
}

