//
//  RegisterModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Request

/// Matches OpenAPI `RegisterRequest`. The backend treats the account by `username`
/// (the iOS UI labels this field «Никнейм» — its value is sent as `username`).
/// Optional fields (`first_name`, `last_name`, `avatar_url`) are not collected
/// in the current sign-up form yet, so they're omitted from the body.
struct RegisterRequest: Encodable {
    let username: String
    let password: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?

    init(
        username: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        avatarUrl: String? = nil
    ) {
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
    }
}

// MARK: - API Response

/// Matches OpenAPI `JWTAuthTokenResponse`.
struct RegisterResponse: Decodable {
    let tokenType: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Validation

enum RegisterValidationError {
    case emailEmpty
    case emailInvalid
    case passwordEmpty
    case passwordDoesNotMeetPolicy
    case passwordsDoNotMatch
    case warningNotAccepted
}

// MARK: - State

enum RegisterState {
    case idle
    case loading
    case error(String)
    case success
}

extension RegisterState: Equatable {
    static func == (lhs: RegisterState, rhs: RegisterState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

extension RegisterValidationError: Equatable {}
