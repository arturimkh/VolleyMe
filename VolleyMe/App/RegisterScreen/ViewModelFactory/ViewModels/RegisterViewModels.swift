//
//  RegisterViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Main ViewModel

struct RegisterViewModel {
    let emailField: RegisterFieldViewModel
    let passwordField: RegisterFieldViewModel
    let confirmPasswordField: RegisterFieldViewModel
    let passwordMismatchError: String?
    /// Shown for local validation failures (empty fields, format, policy) when mismatch label is hidden.
    let validationMessage: String?
    /// API / registration failure after submit.
    let serverErrorMessage: String?
    let submitButton: RegisterButtonViewModel
    let isFormEnabled: Bool
    /// Live password requirement checklist. Empty when the list should be hidden.
    let passwordRequirements: [PasswordRequirementViewModel]
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

// MARK: - Password requirement

struct PasswordRequirementViewModel {
    let text: String
    let isSatisfied: Bool
}
