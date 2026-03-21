//
//  AuthViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Main ViewModel

struct AuthViewModel {
    let title: String
    let nicknameField: AuthFieldViewModel
    let passwordField: AuthFieldViewModel
    let loginButton: AuthButtonViewModel
    let registerButtonTitle: String
    let errorMessage: String?
    let showSuccessState: Bool
    let successTitle: String?
    let successSubtitle: String?
}

// MARK: - Field

struct AuthFieldViewModel {
    let placeholder: String
    let text: String
    let isSecure: Bool
    let hasError: Bool
    let isEnabled: Bool
}

// MARK: - Button

struct AuthButtonViewModel {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
}
