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
        email: String,
        password: String,
        state: AuthState,
        validationErrors: [AuthValidationError]
    ) -> AuthViewModel
}

// MARK: - Implementation

final class AuthViewModelFactory: IAuthViewModelFactory {
    
    func makeViewModel(
        email: String,
        password: String,
        state: AuthState,
        validationErrors: [AuthValidationError]
    ) -> AuthViewModel {
        let isLoading = state == .loading
        let isSuccess = state == .success
        
        let hasEmailError = validationErrors.contains(where: {
            $0 == .emailEmpty || $0 == .emailInvalid
        })
        let hasPasswordError = validationErrors.contains(where: {
            $0 == .passwordEmpty || $0 == .passwordDoesNotMeetPolicy
        })

        let validationMessage: String? = Self.firstValidationMessage(for: validationErrors)

        let errorMessage: String?
        if case .error(let message) = state {
            errorMessage = message
        } else {
            errorMessage = nil
        }
        
        let hasInput = !email.isEmpty && !password.isEmpty
        
        return AuthViewModel(
            title: "Вход",
            emailField: AuthFieldViewModel(
                placeholder: "Никнейм",
                text: email,
                isSecure: false,
                hasError: hasEmailError || errorMessage != nil,
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
            validationMessage: validationMessage,
            errorMessage: errorMessage,
            showSuccessState: isSuccess,
            successTitle: "Рады видеть вас снова!",
            successSubtitle: "Мы уже подготавливаем список ваших встреч."
        )
    }
}

// MARK: - Validation message helper

private extension AuthViewModelFactory {

    static func firstValidationMessage(for errors: [AuthValidationError]) -> String? {
        if errors.contains(.emailEmpty) { return "Введите никнейм." }
        if errors.contains(.emailInvalid) { return PasswordPolicy.nicknameLatinHintRU }
        if errors.contains(.passwordEmpty) { return "Введите пароль." }
        if errors.contains(.passwordDoesNotMeetPolicy) { return PasswordPolicy.requirementHintRU }
        return nil
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
