//
//  SplashView.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import SwiftUI

struct SplashView: View {
    @State private var showLoginView = false

    var body: some View {
        Group {
            if showLoginView {
                LoginView()
            } else {
                    VStack {
                        Image("로고")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Text("봉사당")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showLoginView = true
                        }
                    }
                }
            }
        }
    }
}
