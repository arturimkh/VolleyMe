//
//  RegisterService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Errors

enum RegisterError: Error, LocalizedError {
    case nicknameTaken
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .nicknameTaken:
            return "Этот никнейм уже занят. Попробуйте другой."
        case .networkError(let message):
            return message
        }
    }
}

// MARK: - Protocol

protocol IRegisterService {
    func register(nickname: String, password: String) async throws -> RegisterResponse
}

// MARK: - Implementation

final class RegisterService: IRegisterService {
    
    private let requestProcessor: IRequestProcessor
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    func register(nickname: String, password: String) async throws -> RegisterResponse {
        let body = RegisterRequest(nickname: nickname, password: password)
        let data = try JSONEncoder().encode(body)
        
        do {
            let response: RegisterResponse = try await requestProcessor.post("/auth/register", body: data)
            return response
        } catch let error as NetworkError {
            if case .serverError(409) = error {
                throw RegisterError.nicknameTaken
            }
            throw RegisterError.networkError(error.localizedDescription)
        }
    }
}
