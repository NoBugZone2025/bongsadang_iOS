//
//  LoginViewModel.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isKeepLoggedIn: Bool = false
    @Published var isSecure: Bool = true
    @Published var loginError: String?
    
    private let authUseCase = AuthUseCase()
    
    func login() async {
        print("[LoginViewModel] 로그인 시도: email=\(email)")
        do {
            let tokenData = try await authUseCase.login(email: email, password: password)
            print("[LoginViewModel] 로그인 성공, accessToken=\(tokenData.accessToken), refreshToken=\(tokenData.refreshToken)")
            
            if isKeepLoggedIn {
                KeychainHelper.shared.save(value: tokenData.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(value: tokenData.refreshToken, forKey: "refreshToken")
                print("[LoginViewModel] 토큰 Keychain 저장 완료")
            }
            
            isLoggedIn = true
            loginError = nil
        } catch {
            loginError = "로그인 실패: \(error.localizedDescription)"
            isLoggedIn = false
            print("[LoginViewModel] 로그인 실패: \(error)")
        }
    }
    
    func toggleSecure() {
        isSecure.toggle()
        print("[LoginViewModel] 비밀번호 표시 토글: \(isSecure)")
    }
    
    func checkSavedToken() {
        let access = KeychainHelper.shared.read(forKey: "accessToken")
        let refresh = KeychainHelper.shared.read(forKey: "refreshToken")
        if let access = access, let refresh = refresh {
            isLoggedIn = true
            print("[LoginViewModel] Keychain 토큰 발견: accessToken=\(access), refreshToken=\(refresh)")
        } else {
            isLoggedIn = false
            print("[LoginViewModel] Keychain 토큰 없음")
        }
    }
}

