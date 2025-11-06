import SwiftUI

struct MyRecruitedVolunteersCardView: View {
    let myVolunteers: [VolunteerData]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("내가 모집한 봉사")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.horizontal, 19)

            VStack(spacing: 12) {
                if myVolunteers.isEmpty {
                    Text("모집한 봉사 기록이 없습니다.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    ForEach(myVolunteers) { volunteer in
                        VolunteerRecordItemView(
                            title: volunteer.title,
                            description: volunteer.description,
                            date: volunteer.formattedStartDate,
                            organizer: "by \(volunteer.organizerName)",
                            participants: "\(volunteer.currentParticipants)/\(volunteer.maxParticipants)",
                            location: "", // location is not available in the response
                            time: volunteer.formattedTimeRange,
                            distance: ""
                        )
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
