//
//  AuthAPI.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import Foundation

struct TokenResponse: Codable {
    let status: String
    let message: String
    let data: TokenData
    let timestamp: String
}

struct TokenData: Codable {
    let accessToken: String
    let refreshToken: String
}

struct SignupRequest: Codable {
    let email: String
    let password: String
    let name: String
    let preferredVolunteerTypes: [VolunteerType]
}

struct SignupResponse: Codable {
    let status: String
    let message: String
    let timestamp: String
}

class AuthAPI {
    // 로그인
    static func login(email: String, password: String) async throws -> TokenData {
        let url = URL(string: APIConfig.baseURL + "/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        // HTTP 상태 코드 출력
        if let httpResponse = response as? HTTPURLResponse {
            print("[AuthAPI] HTTP 상태 코드:", httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: responseData)
        return decoded.data
    }

    // 회원가입
    static func signup(_ data: SignupRequest) async throws -> SignupResponse {
        let url = URL(string: APIConfig.baseURL + "/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(data)

        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[AuthAPI] HTTP 상태 코드:", httpResponse.statusCode)
        }

        if let raw = String(data: responseData, encoding: .utf8) {
            print("[AuthAPI] raw response:", raw)
        } else {
            print("[AuthAPI] raw response: 출력 불가")
        }

        return try JSONDecoder().decode(SignupResponse.self, from: responseData)
    }

}
