
import SwiftUI

struct MyVolunteerRecordsCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("나의 봉사 기록")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.horizontal, 19)

            VStack(spacing: 12) {
                VolunteerRecordItemView(
                    title: "독거노인 도시락 배달",
                    description: "따뜻한 마음으로 어르신들께\n도시락을 전달해요",
                    date: "2025.11.15",
                    organizer: "by 김봉사",
                    participants: "3/5",
                    location: "서울시 강남구",
                    time: "14:00-16:00",
                    distance: "1.2km"
                )

                VolunteerRecordItemView(
                    title: "바닷가 쓰레기 줍기",
                    description: "줍깅",
                    date: "2025.12.02",
                    organizer: "by 이봉창",
                    participants: "2/2",
                    location: "부산시 수영구",
                    time: "11:00-13:00",
                    distance: "334km"
                )
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
