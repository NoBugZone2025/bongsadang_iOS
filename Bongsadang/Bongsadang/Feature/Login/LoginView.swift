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
                    .padding(.top, 10)
                    
                    // 실패 메시지
                    if let error = vm.loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                    }
                    
                    Text("또는")
                        .font(.caption)
                        .padding(.top, 5)
                    
                    // 소셜 로그인 (UI만 있음)
                    VStack(spacing: 12) {
                        Button { } label: {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Apple로 로그인")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                        }
                        
                        Button { } label: {
                            HStack {
                                Image(systemName: "g.circle.fill").foregroundColor(.white)
                                Text("Google로 로그인").foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 219/255, green: 68/255, blue: 55/255))
                            .cornerRadius(10)
                        }
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
                .padding(.bottom, 50)
            }
            .fullScreenCover(isPresented: $vm.isLoggedIn) {
                MainView()
            }
            
            .onAppear {
                vm.checkSavedToken()
            }
        }
    }
}
