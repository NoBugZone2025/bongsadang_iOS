
import SwiftUI

struct VerificationCompleteModal: View {
    @Binding var showVerificationComplete: Bool
    @Binding var isParticipating: Bool
    @Binding var currentParticipatingVolunteer: VolunteerData?
    @Binding var elapsedTime: TimeInterval
    var formattedTime: String

    var body: some View {
        VStack(spacing: 0) {
            if let volunteer = currentParticipatingVolunteer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(volunteer.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))

                        Spacer()

                        Text(volunteer.formattedStartDate)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "A0522D"))
                    }

                    HStack(alignment: .top) {
                        Text(volunteer.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(3)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("by \(volunteer.organizerName)")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "A0522D"))

                            Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "D2691E"))
                        }
                    }

                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .padding(.vertical, 4)

                    HStack {
                        Spacer()
                        Text(formattedTime)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8B4513"))
                    }

                    Rectangle()
                        .fill(Color(hex: "FFD1A0"))
                        .frame(height: 2)

                    VStack(spacing: 10) {
                        Text("인증 완료!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "D2691E"))

                        Text("445P 지급!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "D2691E"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .cornerRadius(22)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
            }

            Button(action: {
                withAnimation {
                    showVerificationComplete = false
                    isParticipating = false
                    currentParticipatingVolunteer = nil
                    elapsedTime = 0
                }
            }) {
                Text("확인")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 100)
    }
}
