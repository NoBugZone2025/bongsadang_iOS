
import SwiftUI

struct CreateFormSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "8B4513"))
                .padding(.horizontal, 19)

            content
                .padding(.horizontal, 14)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF7F0"))
        .cornerRadius(24)
        .padding(.horizontal, 10)
    }
}
