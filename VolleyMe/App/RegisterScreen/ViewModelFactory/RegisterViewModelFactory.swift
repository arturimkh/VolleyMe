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
        email: String,
        password: String,
        confirmPassword: String,
        state: RegisterState,
        validationErrors: [RegisterValidationError]
    ) -> RegisterViewModel
}

// MARK: - Implementation

final class RegisterViewModelFactory: IRegisterViewModelFactory {
    
    func makeViewModel(
        email: String,
        password: String,
        confirmPassword: String,
        state: RegisterState,
        validationErrors: [RegisterValidationError]
    ) -> RegisterViewModel {
        let isLoading = state == .loading
        let isSuccess = state == .success
        
        let serverErrorMessage: String? = {
            if case .error(let message) = state { return message }
            return nil
        }()
        
        let hasEmailError = validationErrors.contains(.emailEmpty) || validationErrors.contains(.emailInvalid)
        let hasPolicyError = validationErrors.contains(.passwordDoesNotMeetPolicy)
        let hasPasswordError = validationErrors.contains(.passwordEmpty) || hasPolicyError
        let hasConfirmError = validationErrors.contains(.passwordsDoNotMatch)
        
        let passwordMismatchError: String? = hasConfirmError ? "Пароли не совпадают." : nil
        let validationMessage: String? = hasConfirmError
            ? nil
            : Self.firstValidationMessage(for: validationErrors)
        
        let isEnabled = !isLoading && !isSuccess
        let hasInput = !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
        
        let passwordRequirements = Self.makeRequirements(
            password: password,
            shouldShow: !password.isEmpty || hasPolicyError
        )
        
        return RegisterViewModel(
            emailField: RegisterFieldViewModel(
                placeholder: "Никнейм",
                text: email,
                isSecure: false,
                hasError: hasEmailError,
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
            validationMessage: validationMessage,
            serverErrorMessage: serverErrorMessage,
            submitButton: RegisterButtonViewModel(
                title: isLoading ? "Создаём аккаунт" : "Создать аккаунт",
                isEnabled: hasInput && !isLoading && !isSuccess,
                isLoading: isLoading
            ),
            isFormEnabled: isEnabled,
            passwordRequirements: passwordRequirements,
            showSuccessState: isSuccess,
            successTitle: "Аккаунт создан!",
            successSubtitle: "Мы уже подготавливаем список ваших встреч."
        )
    }
}

// MARK: - Helpers

private extension RegisterViewModelFactory {

    static func firstValidationMessage(for errors: [RegisterValidationError]) -> String? {
        if errors.contains(.emailEmpty) { return "Введите никнейм." }
        if errors.contains(.emailInvalid) { return PasswordPolicy.nicknameLatinHintRU }
        if errors.contains(.passwordEmpty) { return "Введите пароль." }
        // The policy failure is communicated through the live requirements checklist, not the inline label.
        return nil
    }

    static func makeRequirements(password: String, shouldShow: Bool) -> [PasswordRequirementViewModel] {
        guard shouldShow else { return [] }
        return [
            PasswordRequirementViewModel(
                text: PasswordPolicy.RequirementRU.lowerUpper,
                isSatisfied: PasswordPolicy.hasLowerAndUpperCase(password)
            ),
            PasswordRequirementViewModel(
                text: PasswordPolicy.RequirementRU.digit,
                isSatisfied: PasswordPolicy.hasDigit(password)
            ),
            PasswordRequirementViewModel(
                text: PasswordPolicy.RequirementRU.special,
                isSatisfied: PasswordPolicy.hasSpecialCharacter(password)
            ),
            PasswordRequirementViewModel(
                text: PasswordPolicy.RequirementRU.length,
                isSatisfied: PasswordPolicy.hasMinimumLength(password)
            )
        ]
    }
}
