
import SwiftUI

struct TopNavigationBar: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 16)

            Spacer()

            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Image("logoText")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 21)
            }

            Spacer()
            Color.clear
                .frame(width: 56)
        }
        .frame(height: 58)
        .background(Color.white)
    }
}
