//
//  AuthService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Errors

enum AuthError: Error, LocalizedError {
    /// `__USE_CASE_NOT_FOUND__` — no user for given credentials.
    case userNotFound
    /// `__USE_CASE_ERROR__` or wrong password — credentials are correct format but auth rejected.
    case authenticationFailed
    /// `__ACCOUNT_BLOCKED__` — user account is suspended.
    case accountBlocked
    /// HTTP 429 or `__RATE_LIMIT_EXCEEDED__` — too many attempts.
    case rateLimited
    /// HTTP 5xx — backend is down.
    case serverUnavailable
    /// URLError: no connection / timeout.
    case noInternet
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Аккаунт с таким email не найден."
        case .authenticationFailed:
            return "Неверный email или пароль."
        case .accountBlocked:
            return "Ваш аккаунт заблокирован. Обратитесь в поддержку."
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

protocol IAuthService {
    func login(email: String, password: String) async throws -> LoginResponse
}

// MARK: - Implementation

final class AuthService: IAuthService {

    private let requestProcessor: IRequestProcessor

    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(username: email, password: password)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(body)

        do {
            let response: LoginResponse = try await requestProcessor.post("/auth/login/", body: data)
            return response
        } catch let error as NetworkError {
            switch error {
            case .apiError(let apiError):
                throw mapLoginAPIError(apiError)
            case .serverError(let code):
                throw mapLoginHTTPError(code)
            default:
                throw AuthError.networkError(Self.fallbackMessage)
            }
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        }
    }

    private func mapLoginAPIError(_ apiError: APIError) -> AuthError {
        let codes = apiError.allCodes

        if codes.contains(APIError.Code.accountBlocked) {
            return .accountBlocked
        }
        if codes.contains(APIError.Code.rateLimitExceeded) {
            return .rateLimited
        }
        if codes.contains(APIError.Code.useCaseNotFound) {
            return .userNotFound
        }
        if codes.contains(APIError.Code.useCaseError) || codes.contains(APIError.Code.invalidCredentials) {
            return .authenticationFailed
        }

        let msg = apiError.userMessage
        return msg.isEmpty ? .networkError(Self.fallbackMessage) : .networkError(msg)
    }

    private func mapLoginHTTPError(_ statusCode: Int) -> AuthError {
        switch statusCode {
        case 401, 403:
            return .authenticationFailed
        case 404:
            return .userNotFound
        case 429:
            return .rateLimited
        case 500...599:
            return .serverUnavailable
        default:
            return .networkError(Self.fallbackMessage)
        }
    }

    private func mapURLError(_ urlError: URLError) -> AuthError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .cannotConnectToHost:
            return .noInternet
        case .timedOut:
            return .networkError("Время запроса истекло. Попробуйте ещё раз.")
        default:
            return .networkError(Self.fallbackMessage)
        }
    }

    private static let fallbackMessage = "Не удалось войти. Попробуйте позже."
}
