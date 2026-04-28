//
//  RegisterService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Errors

enum RegisterError: Error, LocalizedError {
    /// `__USER_ALREADY_EXISTS__` or HTTP 409 — email is taken.
    case emailAlreadyExists
    /// `__USE_CASE_EMAIL_VALIDATION_FAILED__` or email field error from server.
    case emailInvalidOnServer(String)
    /// `__USE_CASE_PASSWORD_VALIDATION_FAILED__` — password rejected by server policy.
    case passwordValidationFailed(String)
    /// `__USE_CASE_ERROR__` — generic registration failure.
    case registrationFailed
    /// HTTP 429 or `__RATE_LIMIT_EXCEEDED__`.
    case rateLimited
    /// HTTP 5xx — backend is down.
    case serverUnavailable
    /// URLError: no connection / timeout.
    case noInternet
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .emailAlreadyExists:
            return "Этот email уже зарегистрирован. Попробуйте войти."
        case .emailInvalidOnServer(let message):
            return message
        case .passwordValidationFailed(let message):
            return message
        case .registrationFailed:
            return "Не удалось создать аккаунт. Попробуйте позже."
        case .rateLimited:
            return "Слишком много попыток. Подождите немного и попробуйте снова."
        case .serverUnavailable:
            return "Сервер временно недоступен. Попробуйте позже."
        case .noInternet:
            return "Нет подключения к интернету. Проверьте соединение."
        case .networkError(let message):
            return message
        }
    }
}

// MARK: - Protocol

protocol IRegisterService {
    func register(email: String, password: String) async throws -> RegisterResponse
}

// MARK: - Implementation

final class RegisterService: IRegisterService {

    private let requestProcessor: IRequestProcessor

    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }

    func register(email: String, password: String) async throws -> RegisterResponse {
        let body = RegisterRequest(username: email, password: password)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(body)

        do {
            let response: RegisterResponse = try await requestProcessor.post("/auth/register/", body: data)
            return response
        } catch let error as NetworkError {
            switch error {
            case .apiError(let apiError):
                throw mapRegisterAPIError(apiError)
            case .serverError(let code):
                throw mapRegisterHTTPError(code)
            default:
                throw RegisterError.networkError(Self.fallbackMessage)
            }
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        }
    }

    private func mapRegisterAPIError(_ apiError: APIError) -> RegisterError {
        let codes = apiError.allCodes

        if codes.contains(APIError.Code.rateLimitExceeded) {
            return .rateLimited
        }
        if codes.contains(APIError.Code.userAlreadyExists) {
            return .emailAlreadyExists
        }
        if codes.contains(APIError.Code.emailValidationFailed) {
            if let fieldMessages = apiError.messagesForEmailField() {
                let text = fieldMessages.joined(separator: "\n")
                return .emailInvalidOnServer(
                    text.isEmpty ? Self.fallbackEmailValidationMessage : text
                )
            }
            let msg = apiError.userMessage
            return .emailInvalidOnServer(
                msg.isEmpty ? Self.fallbackEmailValidationMessage : msg
            )
        }
        if codes.contains(APIError.Code.passwordValidationFailed) {
            if let fieldMessages = apiError.messagesForPasswordField() {
                let text = fieldMessages.joined(separator: "\n")
                return .passwordValidationFailed(
                    text.isEmpty ? Self.fallbackPasswordValidationMessage : text
                )
            }
            let msg = apiError.userMessage
            return .passwordValidationFailed(
                msg.isEmpty ? Self.fallbackPasswordValidationMessage : msg
            )
        }
        if codes.contains(APIError.Code.useCaseError) {
            return .registrationFailed
        }

        let msg = apiError.userMessage
        return msg.isEmpty ? .networkError(Self.fallbackMessage) : .networkError(msg)
    }

    private func mapRegisterHTTPError(_ statusCode: Int) -> RegisterError {
        switch statusCode {
        case 409:
            return .emailAlreadyExists
        case 429:
            return .rateLimited
        case 500...599:
            return .serverUnavailable
        default:
            return .networkError(Self.fallbackMessage)
        }
    }

    private func mapURLError(_ urlError: URLError) -> RegisterError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .cannotConnectToHost:
            return .noInternet
        case .timedOut:
            return .networkError("Время запроса истекло. Попробуйте ещё раз.")
        default:
            return .networkError(Self.fallbackMessage)
        }
    }

    private static let fallbackMessage = "Не удалось зарегистрироваться. Попробуйте позже."
    private static let fallbackPasswordValidationMessage = "Пароль не прошёл проверку на сервере."
    private static let fallbackEmailValidationMessage = "Некорректный email. Проверьте введённые данные."
}
