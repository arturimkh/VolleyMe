//
//  AuthModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Request

/// Matches OpenAPI `LoginRequest`. The backend authenticates by `username`,
/// the iOS UI labels this field «Никнейм» — its value is sent as `username`.
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

// MARK: - API Response

/// Matches OpenAPI `JWTAuthTokenResponse`.
struct LoginResponse: Decodable {
    let tokenType: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Validation

enum AuthValidationError {
    case emailEmpty
    case emailInvalid
    case passwordEmpty
    case passwordDoesNotMeetPolicy
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
