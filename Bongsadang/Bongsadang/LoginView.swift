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
    @State private var keyboardHeight: CGFloat = 0
    
    enum Field { case email, password }
    
    private func handleKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = value.height
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        // 로고
                        VStack(spacing: 10) {
                            Image("로고")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                        .padding(.top, 30)
                        
                        // 입력창
                        VStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("이메일")
                                TextField("이메일", text: $vm.email)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.5)))
                                    .focused($focusedField, equals: .email)
                                    .id("emailField")
                            }
                            
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
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.5)))
                                .focused($focusedField, equals: .password)
                                .id("passwordField")
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // 로그인 상태 유지 & 비밀번호 찾기
                        HStack {
                            Image(systemName: vm.isKeepLoggedIn ? "checkmark.square" : "square")
                                .onTapGesture { vm.isKeepLoggedIn.toggle() }
                            Text("로그인 상태 유지")
                            Spacer()
                            Button("비밀번호 찾기") {}
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
                        
                        // 로그인 실패 메시지
                        if let error = vm.loginError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top, 5)
                        }
                        
                        Text("또는").font(.caption)
                        
                        // 소셜 로그인
                        VStack(spacing: 12) {
                            Button { } label: {
                                HStack { Image(systemName: "applelogo"); Text("Apple로 로그인").fontWeight(.medium) }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            Button { } label: {
                                HStack { Image(systemName: "g.circle.fill").foregroundColor(.white); Text("Google로 로그인").fontWeight(.medium).foregroundColor(.white) }
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
                                .foregroundColor(.black.opacity(0.8))
                            Button("회원가입") {}
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer().frame(height: max(keyboardHeight - 30, 0))
                        
                        // ✅ 숨겨진 NavigationLink
                        NavigationLink(
                            destination: MainView(),
                            isActive: $vm.isLoggedIn,
                            label: { EmptyView() }
                        )
                    }
                    .padding(.bottom, 100)
                    .onAppear {
                        handleKeyboard()
                        vm.checkSavedToken()
                    }
                    .onDisappear { NotificationCenter.default.removeObserver(self) }
                }
                .onChange(of: focusedField) { field in
                    withAnimation {
                        switch field {
                        case .email: proxy.scrollTo("emailField", anchor: .center)
                        case .password: proxy.scrollTo("passwordField", anchor: .center)
                        default: break
                        }
                    }
                }
                .onTapGesture { hideKeyboard() }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
