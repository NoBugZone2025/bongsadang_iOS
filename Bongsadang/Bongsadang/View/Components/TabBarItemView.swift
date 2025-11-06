
import SwiftUI

struct TabBarItemView: View {
    let icon: String
    let isSelected: Bool
    let action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? Color(hex: "D2691E") : Color.gray.opacity(0.6))
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
    }
}
