//
//  RequestProcessor.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - API Error Response

struct APIError: Decodable {
    let details: [APIErrorDetail]
    
    var userMessage: String {
        let messages = details.flatMap { detail -> [String] in
            let fieldMessages = detail.fields?.values.flatMap { $0.messages } ?? []
            return fieldMessages.isEmpty ? detail.messages : fieldMessages
        }
        return messages.joined(separator: "\n")
    }
}

struct APIErrorDetail: Decodable {
    let code: String
    let messages: [String]
    let fields: [String: APIErrorField]?
}

struct APIErrorField: Decodable {
    let code: String
    let messages: [String]
}

extension APIError {

    enum Code {
        static let useCaseError = "__USE_CASE_ERROR__"
        static let useCaseNotFound = "__USE_CASE_NOT_FOUND__"
        static let userAlreadyExists = "__USER_ALREADY_EXISTS__"
        static let passwordValidationFailed = "__USE_CASE_PASSWORD_VALIDATION_FAILED__"
        static let emailValidationFailed = "__USE_CASE_EMAIL_VALIDATION_FAILED__"
        static let invalidCredentials = "__INVALID_CREDENTIALS__"
        static let accountBlocked = "__ACCOUNT_BLOCKED__"
        static let rateLimitExceeded = "__RATE_LIMIT_EXCEEDED__"
    }

    /// Detail-level and nested field error codes from the API payload.
    var allCodes: Set<String> {
        var result = Set<String>()
        for detail in details {
            result.insert(detail.code)
            if let fields = detail.fields {
                for field in fields.values {
                    result.insert(field.code)
                }
            }
        }
        return result
    }

    /// Messages for the `password` field when present (e.g. `__USE_CASE_PASSWORD_VALIDATION_FAILED__`).
    func messagesForPasswordField() -> [String]? {
        for detail in details {
            if let pwd = detail.fields?["password"], !pwd.messages.isEmpty {
                return pwd.messages
            }
        }
        return nil
    }

    /// Messages for the email/username field when present.
    /// The backend renamed the auth identifier to `username`; iOS UI still presents
    /// an "Email" field, so we accept both keys.
    func messagesForEmailField() -> [String]? {
        for detail in details {
            if let username = detail.fields?["username"], !username.messages.isEmpty {
                return username.messages
            }
            if let email = detail.fields?["email"], !email.messages.isEmpty {
                return email.messages
            }
        }
        return nil
    }
}

// MARK: - Session Notifications

extension Notification.Name {
    /// Posted when the refresh-token flow fails terminally and the user must
    /// be redirected to the auth screen. AppCoordinator subscribes and swaps
    /// the window root.
    static let userSessionExpired = Notification.Name("VolleyMe.userSessionExpired")
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case apiError(APIError)
    /// Authenticated request received 401 and the refresh-token flow could not
    /// recover the session. Local tokens are already cleared by the time this
    /// is thrown.
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Данные не получены"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .apiError(let error):
            return error.userMessage
        case .unauthorized:
            return "Сессия истекла. Войдите снова."
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

// MARK: - Refresh Coordinator

/// Serializes `POST /auth/refresh/` so multiple parallel 401s share one network
/// hop. The backend rotates the refresh token, so a second concurrent call
/// would otherwise fail with 401 against the now-invalid old token.
private actor RefreshCoordinator {
    private var inFlight: Task<AuthTokens, Error>?

    func refresh(using perform: @Sendable @escaping () async throws -> AuthTokens) async throws -> AuthTokens {
        if let inFlight {
            return try await inFlight.value
        }
        let task = Task { try await perform() }
        inFlight = task
        defer { inFlight = nil }
        return try await task.value
    }
}

// MARK: - Request Processor Protocol

protocol IRequestProcessor {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T
    func post(_ endpoint: String, body: Data?) async throws
    func delete(_ endpoint: String) async throws
}

// MARK: - Request Processor Implementation

final class RequestProcessor: IRequestProcessor {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenStorage: ITokenStorage
    private let refreshCoordinator = RefreshCoordinator()

    /// Endpoints that must NOT trigger the refresh-token flow on 401.
    /// They either don't require auth (login/register/refresh) or are part of
    /// terminating the session (logout) where re-authenticating makes no sense.
    private static let authBypassedEndpoints: Set<String> = [
        "/auth/login/",
        "/auth/register/",
        "/auth/refresh/",
        "/auth/logout/"
    ]
    
    // MARK: - Init
    
    init(
        baseURL: String = "https://volleyme.ru",
        session: URLSession = .shared,
        tokenStorage: ITokenStorage
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStorage = tokenStorage
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - IRequestProcessor
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        let data = try await performRaw(endpoint: endpoint, method: "GET", body: nil)
        return try decode(data)
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T {
        let data = try await performRaw(endpoint: endpoint, method: "POST", body: body)
        return try decode(data)
    }
    
    func post(_ endpoint: String, body: Data?) async throws {
        _ = try await performRaw(endpoint: endpoint, method: "POST", body: body)
    }
    
    func delete(_ endpoint: String) async throws {
        _ = try await performRaw(endpoint: endpoint, method: "DELETE", body: nil)
    }
    
    // MARK: - Core flow
    
    /// Sends a request, transparently performs `POST /auth/refresh/` and a one-shot
    /// retry on 401 for non-auth endpoints, and validates the final response.
    private func performRaw(endpoint: String, method: String, body: Data?) async throws -> Data {
        let request = try makeRequest(endpoint: endpoint, method: method, body: body)
        let (data, response) = try await session.data(for: request)

        if isUnauthorized(response), shouldAttemptRefresh(for: endpoint) {
            try await refreshIfPossible()
            let retryRequest = try makeRequest(endpoint: endpoint, method: method, body: body)
            let (retryData, retryResponse) = try await session.data(for: retryRequest)
            try validateResponse(retryResponse, data: retryData)
            return retryData
        }

        try validateResponse(response, data: data)
        return data
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Refresh
    
    /// Attempts to refresh tokens via the shared coordinator. On any failure
    /// clears local tokens, posts `.userSessionExpired`, and throws
    /// `NetworkError.unauthorized` so the calling feature can react.
    private func refreshIfPossible() async throws {
        guard let refreshToken = tokenStorage.tokens?.refreshToken, !refreshToken.isEmpty else {
            handleSessionTerminallyExpired()
            throw NetworkError.unauthorized
        }

        let previousEmail = tokenStorage.tokens?.userEmail
        let baseURL = self.baseURL
        let session = self.session

        do {
            let newTokens = try await refreshCoordinator.refresh {
                try await Self.performRefreshRequest(
                    baseURL: baseURL,
                    session: session,
                    refreshToken: refreshToken,
                    userEmail: previousEmail
                )
            }
            tokenStorage.save(tokens: newTokens)
        } catch {
            handleSessionTerminallyExpired()
            throw NetworkError.unauthorized
        }
    }

    /// Performs `POST /auth/refresh/?refresh_token=...`. Uses no Authorization
    /// header (the server doesn't require it for refresh) and is fully
    /// self-contained so it never re-enters the 401 retry path.
    ///
    /// NOTE: The OpenAPI spec sends the refresh token as a URL query parameter,
    /// which means it can leak into proxy logs and URL caches. Once the backend
    /// adds a body-based variant we should switch to that.
    private static func performRefreshRequest(
        baseURL: String,
        session: URLSession,
        refreshToken: String,
        userEmail: String?
    ) async throws -> AuthTokens {
        guard var components = URLComponents(string: baseURL + "/auth/refresh/") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "refresh_token", value: refreshToken)]
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let payload: RefreshResponsePayload
        do {
            payload = try decoder.decode(RefreshResponsePayload.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }

        return AuthTokens(
            accessToken: payload.accessToken,
            refreshToken: payload.refreshToken,
            userEmail: userEmail
        )
    }

    private func handleSessionTerminallyExpired() {
        tokenStorage.clear()
        NotificationCenter.default.post(name: .userSessionExpired, object: nil)
    }
    
    // MARK: - Private helpers
    
    private func makeRequest(endpoint: String, method: String, body: Data?) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = tokenStorage.tokens?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        return request
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? decoder.decode(APIError.self, from: data) {
                throw NetworkError.apiError(apiError)
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }

    private func isUnauthorized(_ response: URLResponse) -> Bool {
        (response as? HTTPURLResponse)?.statusCode == 401
    }

    private func shouldAttemptRefresh(for endpoint: String) -> Bool {
        !Self.authBypassedEndpoints.contains(endpoint)
    }
}

// MARK: - Refresh DTO

private struct RefreshResponsePayload: Decodable {
    let tokenType: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Mock Request Processor

final class MockRequestProcessor: IRequestProcessor {
    
    // MARK: - Properties
    
    private let decoder: JSONDecoder
    
    var userRole: UserRole = .viewer
    var shouldFail: Bool = false
    var isEventFull: Bool = false
    var hasEvents: Bool = true
    
    enum UserRole {
        case viewer
        case participant
        case host
    }
    
    // MARK: - Init
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - IRequestProcessor
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if endpoint == "/events/" {
            let mockData = createMockEventList()
            let data = try JSONEncoder().encode(mockData)
            return try decoder.decode(T.self, from: data)
        }
        
        if endpoint.contains("/events/") {
            let mockData = createMockEventDetails()
            let data = try JSONEncoder().encode(mockData)
            return try decoder.decode(T.self, from: data)
        }
        
        throw NetworkError.noData
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if endpoint == "/auth/login/" || endpoint == "/auth/register/" {
            let response: [String: String] = [
                "token_type": "Bearer",
                "access_token": "mock_access_token_\(UUID().uuidString)",
                "refresh_token": "mock_refresh_token_\(UUID().uuidString)"
            ]
            let data = try JSONEncoder().encode(response)
            return try decoder.decode(T.self, from: data)
        }
        
        throw NetworkError.noData
    }
    
    func post(_ endpoint: String, body: Data?) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if isEventFull && endpoint.contains("/join/") {
            throw NetworkError.serverError(409)
        }
        
        if endpoint == "/events/" {
            return
        }
    }
    
    func delete(_ endpoint: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
    }
    
    // MARK: - Mock Data
    
    private func createMockEventList() -> MockPaginatedEventListResponse {
        guard hasEvents else {
            return MockPaginatedEventListResponse(nextUrl: "", prevUrl: nil, items: [])
        }
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        func dateString(_ day: Date, hour: Int, minute: Int = 0) -> String {
            let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
            return formatter.string(from: date)
        }
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let later1 = calendar.date(byAdding: .day, value: 4, to: today)!
        let later2 = calendar.date(byAdding: .day, value: 6, to: today)!
        let later3 = calendar.date(byAdding: .day, value: 8, to: today)!
        let later4 = calendar.date(byAdding: .day, value: 10, to: today)!
        
        let items = [
            MockEventListItemResponse(id: UUID().uuidString, title: "Большая дружеская встреча по волейболу на снегу", startDt: dateString(today, hour: 18), city: "Красноярск", address: "ул. Победы, 33", price: "650", participantsCount: 12, maxParticipantsCount: 16, myRole: "host", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Тренировка в зале", startDt: dateString(tomorrow, hour: 12), city: "Красноярск", address: "ул. Центральная, 5", price: "0", participantsCount: 4, maxParticipantsCount: 12, myRole: "participant", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Командная встреча", startDt: dateString(later1, hour: 12), city: "Красноярск", address: "ул. Победы, 33", price: "650", participantsCount: 12, maxParticipantsCount: 12, myRole: "host", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Тренировка в зале", startDt: dateString(later2, hour: 15), city: "Красноярск", address: "ул. Центральная, 5", price: "0", participantsCount: 12, maxParticipantsCount: 12, myRole: "host", isPublic: false, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Тренировка в зале", startDt: dateString(later3, hour: 15), city: "Красноярск", address: "ул. Центральная, 5", price: "0", participantsCount: 2, maxParticipantsCount: 12, myRole: "participant", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Вечерняя игра", startDt: dateString(later4, hour: 18), city: "Красноярск", address: "ул. Спортивная, 10", price: "0", participantsCount: 8, maxParticipantsCount: 12, myRole: "participant", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Открытая тренировка для новичков", startDt: dateString(today, hour: 20), city: "Красноярск", address: "ул. Ленина, 15", price: "0", participantsCount: 6, maxParticipantsCount: 14, myRole: "nobody", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0),
            MockEventListItemResponse(id: UUID().uuidString, title: "Турнир 4x4", startDt: dateString(tomorrow, hour: 18), city: "Красноярск", address: "ул. Спортивная, 22", price: "500", participantsCount: 16, maxParticipantsCount: 16, myRole: "nobody", isPublic: true, imageUrls: [], country: "RU", currency: "RUB", gameType: 0)
        ]
        
        return MockPaginatedEventListResponse(nextUrl: "", prevUrl: nil, items: items)
    }
    
    private func createMockEventDetails() -> MockEventDetailsResponse {
        let myRole: String
        switch userRole {
        case .viewer: myRole = "nobody"
        case .participant: myRole = "participant"
        case .host: myRole = "host"
        }
        
        return MockEventDetailsResponse(
            id: UUID().uuidString,
            title: "Дружеская встреча по волейболу на снегу",
            startDt: "2025-11-27T18:15:00+07:00",
            endDt: "2025-11-27T20:45:00+07:00",
            city: "Красноярск",
            address: "ул. Красноармейская, д. 113",
            participantsCount: 3,
            maxParticipantsCount: 12,
            myRole: myRole,
            price: "600",
            currency: "RUB",
            description: "Привет! Игры пройдут 27 ноября с 18:15 до 20:45. Формат: 3×3.",
            participants: [
                MockParticipantResponse(id: UUID().uuidString, avatarUrl: nil, name: "leonid_smirnov"),
                MockParticipantResponse(id: UUID().uuidString, avatarUrl: nil, name: "michel"),
                MockParticipantResponse(id: UUID().uuidString, avatarUrl: nil, name: "artur")
            ],
            hosts: [
                MockParticipantResponse(id: UUID().uuidString, avatarUrl: nil, name: "artur")
            ],
            isPublic: true,
            imageUrls: [],
            country: "RU",
            gameType: 0,
            formatType: 0
        )
    }
}

// MARK: - Mock Codable Helpers

private struct MockPaginatedEventListResponse: Encodable {
    let nextUrl: String
    let prevUrl: String?
    let items: [MockEventListItemResponse]
}

private struct MockEventListItemResponse: Encodable {
    let id: String
    let title: String
    let startDt: String
    let city: String
    let address: String
    let price: String
    let participantsCount: Int
    let maxParticipantsCount: Int
    let myRole: String
    let isPublic: Bool
    let imageUrls: [String]
    let country: String
    let currency: String
    let gameType: Int
}

private struct MockEventDetailsResponse: Encodable {
    let id: String
    let title: String
    let startDt: String
    let endDt: String
    let city: String
    let address: String
    let participantsCount: Int
    let maxParticipantsCount: Int
    let myRole: String
    let price: String
    let currency: String
    let description: String
    let participants: [MockParticipantResponse]
    let hosts: [MockParticipantResponse]
    let isPublic: Bool
    let imageUrls: [String]
    let country: String
    let gameType: Int
    let formatType: Int
}

private struct MockParticipantResponse: Encodable {
    let id: String
    let avatarUrl: String?
    let name: String?
}
