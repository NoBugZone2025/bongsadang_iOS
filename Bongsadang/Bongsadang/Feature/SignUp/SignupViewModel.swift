//
//  SignupViewModel.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import Foundation
import Combine

@MainActor
class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var selectedTypes: [VolunteerType] = []
    @Published var signupMessage: String?
    @Published var isSignupSuccess: Bool = false

    func toggleType(_ type: VolunteerType) {
        if selectedTypes.contains(type) {
            selectedTypes.removeAll { $0 == type }
        } else {
            selectedTypes.append(type)
        }
    }

    func signup() async {
        let request = SignupRequest(
            email: email,
            password: password,
            name: name,
            preferredVolunteerTypes: selectedTypes
        )

        do {
            print("[SignupViewModel] 요청 Body:", request)
            let response = try await AuthAPI.signup(request)
            signupMessage = "회원가입 성공"
            isSignupSuccess = true
            print("[SignupViewModel] 회원가입 성공:", response)
        } catch {
            signupMessage = "회원가입 실패"
            isSignupSuccess = false
            print("[SignupViewModel] 회원가입 실패:", error)
        }
    }
}
