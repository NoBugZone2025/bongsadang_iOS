//
//  LoginView.swift
//  Bongsadang
//
//  Created by 박정우 on 11/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSecure = true
    @State private var isKeepLoggedIn = false
    @State private var keyboardHeight: CGFloat = 0

    @FocusState private var focusedField: Field?
    
    enum Field {
        case email
        case password
    }
    
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
        ScrollViewReader { proxy in
            ScrollView {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 10) {
                        
                        VStack(spacing: 10) {
                            Image("로고")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.white)
                            
                            Text("봉사당")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 30)
                        
                        VStack(spacing: 15) {
                            // 이메일 입력란
                            VStack(alignment: .leading, spacing: 5) {
                                Text("이메일")
                                    .font(.system(size: 15))
                                TextField("이메일", text: $email)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 0.5)
                                    )
                                    .focused($focusedField, equals: .email)
                                    .id("emailField")
                            }
                            
                            // 비밀번호 입력란
                            VStack(alignment: .leading, spacing: 5) {
                                Text("비밀번호")
                                    .font(.system(size: 15))
                                HStack {
                                    if isSecure {
                                        SecureField("비밀번호", text: $password)
                                    } else {
                                        TextField("비밀번호", text: $password)
                                    }
                                    
                                    Button {
                                        isSecure.toggle()
                                    } label: {
                                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 0.5)
                                )
                                .focused($focusedField, equals: .password)
                                .id("passwordField")
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // 로그인 상태 유지 체크박스
                        HStack {
                            HStack {
                                Image(systemName: isKeepLoggedIn ? "checkmark.square" : "square")
                                    .onTapGesture {
                                        isKeepLoggedIn.toggle()
                                    }
                                Text("로그인 상태 유지")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button("비밀번호 찾기") {}
                                .font(.footnote)
                                .foregroundColor(.black.opacity(0.9))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        
                        // 로그인 버튼
                        Button {
                            // 로그인 액션
                        } label: {
                            Text("로그인")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 10)
                        
                        Text("또는")
                            .font(.caption)
                        
                        // 소셜 로그인 버튼들
                        VStack(spacing: 12) {
                            Button {
                                // Apple 로그인 액션
                            } label: {
                                HStack {
                                    Image(systemName: "applelogo")
                                    Text("Apple로 로그인")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                            }
                            
                            Button {
                                // Google 로그인 액션
                            } label: {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .foregroundColor(.white)
                                    Text("Google로 로그인")
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 219/255, green: 68/255, blue: 55/255))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // 회원가입 버튼
                        VStack(spacing: 8) {
                            HStack {
                                Text("계정이 없으신가요?")
                                    .foregroundColor(.black.opacity(0.8))
                                Button("회원가입") {}
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        // 키보드에 맞춰서 스크롤 조정
                        Spacer()
                            .frame(height: max(keyboardHeight - 30, 0))
                        
                    }
                    .padding(.bottom, 100)
                    .onAppear {
                        handleKeyboard()
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self)
                    }
                }
            }
            .onChange(of: focusedField) { field in
                withAnimation(.easeInOut) {
                    switch field {
                    case .email:
                        proxy.scrollTo("emailField", anchor: .center)
                    case .password:
                        proxy.scrollTo("passwordField", anchor: .center)
                    default:
                        break
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
