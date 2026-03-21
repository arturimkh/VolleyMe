//
//  RegisterModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Request

struct RegisterRequest: Encodable {
    let nickname: String
    let password: String
}

// MARK: - API Response

struct RegisterResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Validation

enum RegisterValidationError {
    case nicknameEmpty
    case nicknameTooShort
    case passwordEmpty
    case passwordTooShort
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
