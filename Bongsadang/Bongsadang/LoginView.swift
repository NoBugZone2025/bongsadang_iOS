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
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    Image("로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                    
                    Text("봉사당")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                
                VStack(spacing: 15) {
                    VStack(alignment:. leading, spacing: 5){
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
                    }
                    
                    VStack(alignment:. leading, spacing: 5){
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
                    }
                    
                }
                .padding(.horizontal, 32)
                
                HStack{
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
                .padding(.horizontal,30)
                
                
                Button {
               
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
                
                VStack(spacing: 12) {
                    Button {
                        
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
                
                
                VStack(spacing: 8) {
                    HStack {
                        Text("계정이 없으신가요?")
                            .foregroundColor(.black.opacity(0.8))
                        Button("회원가입") {}
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 12)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
