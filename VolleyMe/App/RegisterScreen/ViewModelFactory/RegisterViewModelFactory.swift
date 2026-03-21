//
//  RegisterViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Protocol

protocol IRegisterViewModelFactory {
    func makeViewModel(
        nickname: String,
        password: String,
        confirmPassword: String,
        state: RegisterState,
        validationErrors: [RegisterValidationError]
    ) -> RegisterViewModel
}

// MARK: - Implementation

final class RegisterViewModelFactory: IRegisterViewModelFactory {
    
    func makeViewModel(
        nickname: String,
        password: String,
        confirmPassword: String,
        state: RegisterState,
        validationErrors: [RegisterValidationError]
    ) -> RegisterViewModel {
        let isLoading = state == .loading
        let isSuccess = state == .success
        
        let hasNicknameError = validationErrors.contains(.nicknameEmpty) || validationErrors.contains(.nicknameTooShort)
        let hasPasswordError = validationErrors.contains(.passwordEmpty) || validationErrors.contains(.passwordTooShort)
        let hasConfirmError = validationErrors.contains(.passwordsDoNotMatch)
        
        let passwordMismatchError: String? = hasConfirmError ? "Пароли не совпадают." : nil
        
        let isEnabled = !isLoading && !isSuccess
        let hasInput = !nickname.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
        
        return RegisterViewModel(
            nicknameField: RegisterFieldViewModel(
                placeholder: "Никнейм",
                text: nickname,
                isSecure: false,
                hasError: hasNicknameError,
                isEnabled: isEnabled
            ),
            passwordField: RegisterFieldViewModel(
                placeholder: "Пароль",
                text: password,
                isSecure: true,
                hasError: hasPasswordError || hasConfirmError,
                isEnabled: isEnabled
            ),
            confirmPasswordField: RegisterFieldViewModel(
                placeholder: "Повторите пароль",
                text: confirmPassword,
                isSecure: true,
                hasError: hasConfirmError,
                isEnabled: isEnabled
            ),
            passwordMismatchError: passwordMismatchError,
            submitButton: RegisterButtonViewModel(
                title: isLoading ? "Создаём аккаунт" : "Создать аккаунт",
                isEnabled: hasInput && !isLoading && !isSuccess,
                isLoading: isLoading
            ),
            isFormEnabled: isEnabled,
            showSuccessState: isSuccess,
            successTitle: "Аккаунт создан!",
            successSubtitle: "Мы уже подготавливаем список ваших встреч."
        )
    }
}
