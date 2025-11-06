
import SwiftUI
import MapKit

struct VolunteerDetailCardView: View {
    @Binding var selectedLocation: VolunteerLocation?
    var region: MKCoordinateRegion
    let startParticipation: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            if let location = selectedLocation {
                let volunteer = location.volunteerData

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(volunteer.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "8B4513"))

                        Spacer()

                        Text(volunteer.formattedStartDate)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "A0522D"))
                    }

                    HStack(alignment: .top) {
                        Text(volunteer.description)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "A0522D"))
                            .lineSpacing(4)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("by \(volunteer.organizerName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))

                            Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "D2691E"))
                        }
                    }

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(getLocationText(volunteer))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(volunteer.formattedTimeRange)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B4513"))
                            Text(getDistanceText(volunteer))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A0522D"))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FFF7F0"))
                .cornerRadius(24)
            }

            HStack(spacing: 16) {
                Button(action: { selectedLocation = nil }) {
                    Text("돌아가기")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(28)
                }

                Button(action: { startParticipation() }) {
                    Text("참가하기")
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
            }
            .padding(.horizontal, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private func getLocationText(_ volunteer: VolunteerData) -> String {
        return "위도: \(String(format: "%.2f", volunteer.latitude))"
    }

    private func getDistanceText(_ volunteer: VolunteerData) -> String {
        let centerLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let volunteerLocation = CLLocation(latitude: volunteer.latitude, longitude: volunteer.longitude)
        let distance = centerLocation.distance(from: volunteerLocation)

        if distance < 1000 {
            return String(format: "%.0fm", distance)
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}
