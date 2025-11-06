
import SwiftUI

struct FloatingActionButton: View {
    @Binding var showCreateVolunteerModal: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                showCreateVolunteerModal.toggle()
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Color(hex: "#F6AD55")
                )
                .cornerRadius(28)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}
