//
//  AuthModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Request

struct LoginRequest: Encodable {
    let nickname: String
    let password: String
}

// MARK: - API Response

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Validation

enum AuthValidationError {
    case nicknameEmpty
    case nicknameTooShort
    case passwordEmpty
    case passwordTooShort
}

struct AuthValidationResult {
    let isValid: Bool
    let errors: [AuthValidationError]
}

// MARK: - Auth State

enum AuthState {
    case idle
    case loading
    case error(String)
    case success
}
