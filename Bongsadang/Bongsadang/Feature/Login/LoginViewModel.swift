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
            print("[LoginViewModel] 로그인 성공")
            print("accessToken = \(tokenData.accessToken)")
            print("refreshToken = \(tokenData.refreshToken)")
            
            if isKeepLoggedIn {
                KeychainHelper.shared.save(value: tokenData.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(value: tokenData.refreshToken, forKey: "refreshToken")
                print("[Keychain] 토큰 저장 완료")
            } else {
                KeychainHelper.shared.delete(forKey: "accessToken")
                KeychainHelper.shared.delete(forKey: "refreshToken")
                print("[Keychain] 토큰 삭제 완료")
            }
            
            let savedAccess = KeychainHelper.shared.read(forKey: "accessToken") ?? "nil"
            let savedRefresh = KeychainHelper.shared.read(forKey: "refreshToken") ?? "nil"
            print("[Keychain] 저장 확인 accessToken:", savedAccess)
            print("[Keychain] 저장 확인 refreshToken:", savedRefresh)
            
            isLoggedIn = true
            loginError = nil
            
        } catch {
            loginError = "로그인 실패"
            isLoggedIn = false
            print("[LoginViewModel] 로그인 실패: \(error)")
        }
    }
    
    func toggleSecure() {
        isSecure.toggle()
        print("[LoginViewModel] 비밀번호 표시 토글: \(isSecure)")
    }
    
    func checkSavedToken() {
        if let accessToken = KeychainHelper.shared.read(forKey: "accessToken"), !accessToken.isEmpty {
            print("[LoginViewModel] 자동 로그인 성공")
            isLoggedIn = true
        } else {
            print("[LoginViewModel] 저장된 토큰 없음")
            isLoggedIn = false
        }
    }
}
