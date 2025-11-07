
import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 20)

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("원하는 지역을 입력하세요")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "828282"))
                }
                TextField("", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "333333"))
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        isSearchFocused = false
                    }
            }
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 20)
            }

            Spacer()
        }
        .frame(height: 44)
        .background(Color(hex: "FFF8DC"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "F5DEB3"), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .padding(.top, 9)
    }
}
