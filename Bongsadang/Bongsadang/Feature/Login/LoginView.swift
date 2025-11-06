//
//  LoginView.swift
//  Bongsadang
//
//  Created by 박정우 on 11/5/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field { case email, password }
    
    var body: some View {
        NavigationStack {
            ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 10) {
                        
                        // 로고
                        Image("로고")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.top, 30)
                        
                        // 이메일 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일")
                            TextField("이메일", text: $vm.email)
                                .textInputAutocapitalization(.none)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.5)))
                                .focused($focusedField, equals: .email)
                        }
                        .padding(.horizontal, 32)
                        
                        // 비밀번호 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호")
                            HStack {
                                if vm.isSecure {
                                    SecureField("비밀번호", text: $vm.password)
                                } else {
                                    TextField("비밀번호", text: $vm.password)
                                }
                                Button { vm.toggleSecure() } label: {
                                    Image(systemName: vm.isSecure ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.5)))
                            .focused($focusedField, equals: .password)
                        }
                        .padding(.horizontal, 32)
                        
                        HStack {
                            Image(systemName: vm.isKeepLoggedIn ? "checkmark.square" : "square")
                                .onTapGesture { vm.isKeepLoggedIn.toggle() }
                            Text("로그인 상태 유지")
                            Spacer()
                            Button("비밀번호 찾기") {}
                        }
                        .padding(.horizontal, 32)
                        
                        // 실패 메시지
                        if let error = vm.loginError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top, 5)
                        }
                        
                        Spacer()
                        
                        // 로그인 버튼
                        Button {
                            Task { await vm.login() }
                        } label: {
                            Text("로그인")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 32)
                        
                        // 회원가입
                        HStack {
                            Text("계정이 없으신가요?")
                            NavigationLink("회원가입") {
                                SignupView()
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        }
                        .padding(.top, 10)
                        
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .fullScreenCover(isPresented: $vm.isLoggedIn) {
                VolunteerDetailView(loginViewModel: vm)
            }
            
            .onAppear {
                vm.checkSavedToken()
            }
        }
        }
    }
}
