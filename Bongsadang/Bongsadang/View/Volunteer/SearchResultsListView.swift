
import SwiftUI

struct SearchResultsListView: View {
    let volunteers: [VolunteerData]
    let onSelectVolunteer: (VolunteerData) -> Void
    @FocusState.Binding var isSearchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(volunteers) { volunteer in
                    SearchResultCard(volunteer: volunteer)
                        .onTapGesture {
                            isSearchFocused = false
                            onSelectVolunteer(volunteer)
                        }
                }
            }
            .padding(.vertical, 5)
        }
        .frame(maxHeight: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onTapGesture {
            isSearchFocused = false
        }
    }
}

struct SearchResultCard: View {
    let volunteer: VolunteerData

    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "D2691E"), Color(hex: "F6AD55")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(volunteer.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "8B4513"))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A1A1A1"))
                    Text(volunteer.organizerName)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A1A1A1"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A1A1A1"))
                    Text(volunteer.formattedTimeRange)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A1A1A1"))
                }
            }

            Spacer()

            // 참여자 정보
            VStack(spacing: 4) {
                Text("\(volunteer.currentParticipants)/\(volunteer.maxParticipants)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "D2691E"))

                Text("참여중")
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "A1A1A1"))
            }
        }
        .padding(12)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(16)
    }
}
