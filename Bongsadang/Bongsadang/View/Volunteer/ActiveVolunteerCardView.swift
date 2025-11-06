
import SwiftUI

struct ActiveVolunteerCardView: View {
    @Binding var currentParticipatingVolunteer: VolunteerData?
    @Binding var elapsedTime: TimeInterval
    let totalDuration: TimeInterval
    @Binding var showImagePicker: Bool

    var progress: Double {
        min(elapsedTime / totalDuration, 1.0)
    }

    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let volunteer = currentParticipatingVolunteer {
                VStack(alignment: .leading, spacing: 8) {
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
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(2)

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

                    VStack(spacing: 6) {
                        HStack {
                            Spacer()
                            Text(formattedTime)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(Color(hex: "8B4513"))
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 2)
                                Rectangle()
                                    .fill(Color(hex: "FFD1A0"))
                                    .frame(width: geometry.size.width * progress, height: 2)
                            }
                        }
                        .frame(height: 2)
                    }

                    if elapsedTime >= totalDuration {
                        HStack {
                            Spacer()
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Text("인증하기")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 33.14)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16.57)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
            }
        }
        .frame(height: 200)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
}
