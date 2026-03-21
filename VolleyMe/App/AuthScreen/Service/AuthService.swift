//
//  AuthService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Errors

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неправильный никнейм или пароль."
        case .networkError(let message):
            return message
        }
    }
}

// MARK: - Protocol

protocol IAuthService {
    func login(nickname: String, password: String) async throws -> LoginResponse
}

// MARK: - Implementation

final class AuthService: IAuthService {
    
    private let requestProcessor: IRequestProcessor
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    func login(nickname: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(nickname: nickname, password: password)
        let data = try JSONEncoder().encode(body)
        
        do {
            let response: LoginResponse = try await requestProcessor.post("/auth/login", body: data)
            return response
        } catch let error as NetworkError {
            if case .serverError(401) = error {
                throw AuthError.invalidCredentials
            }
            throw AuthError.networkError(error.localizedDescription)
        }
    }
}
