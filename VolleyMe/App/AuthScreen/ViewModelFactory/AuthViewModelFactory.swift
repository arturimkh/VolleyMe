//
//  AuthViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Protocol

protocol IAuthViewModelFactory {
    func makeViewModel(
        nickname: String,
        password: String,
        state: AuthState,
        validationErrors: [AuthValidationError]
    ) -> AuthViewModel
}

// MARK: - Implementation

final class AuthViewModelFactory: IAuthViewModelFactory {
    
    func makeViewModel(
        nickname: String,
        password: String,
        state: AuthState,
        validationErrors: [AuthValidationError]
    ) -> AuthViewModel {
        let isLoading = state == .loading
        let isSuccess = state == .success
        
        let hasNicknameError = validationErrors.contains(where: {
            $0 == .nicknameEmpty || $0 == .nicknameTooShort
        })
        let hasPasswordError = validationErrors.contains(where: {
            $0 == .passwordEmpty || $0 == .passwordTooShort
        })
        
        let errorMessage: String?
        if case .error(let message) = state {
            errorMessage = message
        } else {
            errorMessage = nil
        }
        
        let hasInput = !nickname.isEmpty && !password.isEmpty
        
        return AuthViewModel(
            title: "Вход",
            nicknameField: AuthFieldViewModel(
                placeholder: "Никнейм",
                text: nickname,
                isSecure: false,
                hasError: hasNicknameError || errorMessage != nil,
                isEnabled: !isLoading && !isSuccess
            ),
            passwordField: AuthFieldViewModel(
                placeholder: "Пароль",
                text: password,
                isSecure: true,
                hasError: hasPasswordError || errorMessage != nil,
                isEnabled: !isLoading && !isSuccess
            ),
            loginButton: AuthButtonViewModel(
                title: isLoading ? "Натягиваем сеть" : "Войти",
                isEnabled: hasInput && !isLoading && !isSuccess,
                isLoading: isLoading
            ),
            registerButtonTitle: "Создать аккаунт",
            errorMessage: errorMessage,
            showSuccessState: isSuccess,
            successTitle: "Рады видеть вас снова!",
            successSubtitle: "Мы уже подготавливаем список ваших встреч."
        )
    }
}

// MARK: - AuthValidationError + Equatable

extension AuthValidationError: Equatable {}

// MARK: - AuthState + Equatable

extension AuthState: Equatable {
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
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
