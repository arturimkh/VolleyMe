//
//  RegisterViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Main ViewModel

struct RegisterViewModel {
    let nicknameField: RegisterFieldViewModel
    let passwordField: RegisterFieldViewModel
    let confirmPasswordField: RegisterFieldViewModel
    let passwordMismatchError: String?
    let submitButton: RegisterButtonViewModel
    let isFormEnabled: Bool
    let showSuccessState: Bool
    let successTitle: String?
    let successSubtitle: String?
}

// MARK: - Field

struct RegisterFieldViewModel {
    let placeholder: String
    let text: String
    let isSecure: Bool
    let hasError: Bool
    let isEnabled: Bool
}

// MARK: - Button

struct RegisterButtonViewModel {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
}
