
import SwiftUI

struct VolunteerRecordItemView: View {
    let title: String
    let description: String
    let date: String
    let organizer: String
    let participants: String
    let location: String
    let time: String
    let distance: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "8B4513"))

                Spacer()

                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "A0522D"))
            }

            HStack(alignment: .top) {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "A0522D"))
                    .lineSpacing(3)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(organizer)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))

                    Text(participants)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "D2691E"))
                }
            }

            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(location)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(time)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B4513"))
                    Text(distance)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "A0522D"))
                }
            }
        }
        .padding(17)
        .background(Color.white)
        .cornerRadius(22)
    }
}
