//
//  SignupView.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TextField("이메일", text: $vm.email)
                    .textInputAutocapitalization(.none)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke())

                TextField("비밀번호", text: $vm.password)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke())

                TextField("이름", text: $vm.name)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke())

                Text("관심 봉사 분야")
                    .font(.headline)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(VolunteerType.allCases) { type in
                        HStack {
                            Image(systemName: vm.selectedTypes.contains(type) ? "checkmark.square" : "square")
                                .onTapGesture { vm.toggleType(type) }
                            Text(type.label)
                        }
                    }
                }
                .padding(.horizontal, 4)

                Button {
                    Task { await vm.signup() }
                } label: {
                    Text("회원가입")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if let msg = vm.signupMessage {
                    Text(msg)
                        .foregroundColor(msg.contains("성공") ? .green : .red)
                        .padding(.top, 4)
                }

            }
            .padding()
        }
        .navigationTitle("회원가입")
        .onChange(of: vm.isSignupSuccess) { success in
            if success { dismiss() }
        }
    }
}
