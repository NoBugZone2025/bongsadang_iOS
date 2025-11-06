//
//  Usecase.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import Foundation

class AuthUseCase {
    func login(email: String, password: String) async throws -> LoginResponseData {
        guard let url = URL(string: "https://mouse-loud-muscle-advanced.trycloudflare.com/auth/login") else {
            throw URLError(.badURL)
        }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[AuthUseCase] 요청 준비 완료: \(body)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[AuthUseCase] HTTP 상태 코드: \(httpResponse.statusCode)")
        }
        
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        print("[AuthUseCase] 응답 데이터: \(decoded)")
        return decoded.data
    }
}
