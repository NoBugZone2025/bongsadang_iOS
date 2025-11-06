
import SwiftUI

struct TopNavigationBar: View {
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image("로고만")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Image("logoText")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 21)
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            Color.clear
                .frame(width: 56)
        }
        .frame(height: 58)
        .background(Color.white)
    }
}
