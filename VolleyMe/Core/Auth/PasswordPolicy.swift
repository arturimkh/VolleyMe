//
//  PasswordPolicy.swift
//  VolleyMe
//

import Foundation

enum PasswordPolicy {

    /// Client-side rule aligned with backend expectations (before login/register requests).
    /// Uses ASCII `[a-z]` / `[A-Z]` only — Cyrillic letters are **not** counted as lower/upper case.
    static let strengthRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%^&+=!])(?=\\S+$).{8,}$"

    static let minimumLength = 8
    static let allowedSpecialCharacters = "@#$%^&+=!"

    static func isValid(_ password: String) -> Bool {
        password.range(of: strengthRegex, options: .regularExpression) != nil
    }

    // MARK: - Per-rule checks (for live validation UI)

    static func hasLowerAndUpperCase(_ password: String) -> Bool {
        let hasLower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        return hasLower && hasUpper
    }

    static func hasDigit(_ password: String) -> Bool {
        password.range(of: "[0-9]", options: .regularExpression) != nil
    }

    static func hasSpecialCharacter(_ password: String) -> Bool {
        password.range(of: "[@#$%^&+=!]", options: .regularExpression) != nil
    }

    static func hasMinimumLength(_ password: String) -> Bool {
        password.count >= minimumLength && !password.contains(" ")
    }

    // MARK: - Localised strings

    static let requirementHintRU =
        "Минимум 8 символов: строчная и заглавная буква латиницы (a–z и A–Z), цифра (0–9) и символ из @#$%^&+=!, без пробелов."

    /// Shown when the login/register identifier format is invalid (avoids duplicate Latin note).
    static let nicknameLatinHintRU =
        "Никнейм укажите латиницей: латинские буквы, цифры и символы (например, user или user@mail.com)."

    enum RequirementRU {
        static let lowerUpper = "Минимум одна строчная и заглавная буква (A-z)"
        static let digit = "Минимум одна цифра (0-9)"
        static let special = "Минимум один специальный символ"
        static let length = "Минимум 8 символов"
    }
}
