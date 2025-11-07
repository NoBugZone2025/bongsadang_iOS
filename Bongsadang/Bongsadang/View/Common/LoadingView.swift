
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(2.0)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "F6AD55")))
                .padding(40)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
        }
    }
}
