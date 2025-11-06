//
//  LoginResponse.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//

import Foundation

struct LoginResponseData: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct LoginResponse: Decodable {
    let status: String
    let message: String
    let data: LoginResponseData
    let timestamp: String
}
