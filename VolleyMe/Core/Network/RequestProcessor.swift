//
//  RequestProcessor.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
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
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

// MARK: - Request Processor Protocol

protocol IRequestProcessor {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T
    func post(_ endpoint: String, body: Data?) async throws
}

// MARK: - Request Processor Implementation

final class RequestProcessor: IRequestProcessor {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Init
    
    init(
        baseURL: String = "https://api.volleyme.app",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - IRequestProcessor
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func post(_ endpoint: String, body: Data?) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (_, response) = try await session.data(for: request)
        
        try validateResponse(response)
    }
    
    // MARK: - Private
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Mock Request Processor

final class MockRequestProcessor: IRequestProcessor {
    
    // MARK: - Properties
    
    private let decoder: JSONDecoder
    
    // Для тестирования разных состояний
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
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 сек
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if endpoint == "/events" {
            let mockData = createMockEventList()
            let data = try JSONEncoder().encode(mockData)
            return try decoder.decode(T.self, from: data)
        }
        
        if endpoint.contains("/event/") {
            let mockData = createMockEventDetails()
            let data = try JSONEncoder().encode(mockData)
            return try decoder.decode(T.self, from: data)
        }
        
        throw NetworkError.noData
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T {
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 сек
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if endpoint == "/auth/login" || endpoint == "/auth/register" {
            let response = [
                "accessToken": "mock_access_token_\(UUID().uuidString)",
                "refreshToken": "mock_refresh_token_\(UUID().uuidString)"
            ]
            let data = try JSONEncoder().encode(response)
            return try JSONDecoder().decode(T.self, from: data)
        }
        
        throw NetworkError.noData
    }
    
    func post(_ endpoint: String, body: Data?) async throws {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 сек
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        if isEventFull && endpoint.contains("/join/") {
            throw NetworkError.serverError(409) // Conflict - все места заняты
        }
        
        // Для создания события - просто успешно завершаем
        if endpoint == "/events" {
            return
        }
    }
    
    // MARK: - Mock Data
    
    private func createMockEventList() -> EventListResponse {
        guard hasEvents else {
            return EventListResponse(items: [])
        }
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        func dateString(_ day: Date, hour: Int, minute: Int = 0) -> String {
            let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
            return formatter.string(from: date)
        }
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let later1 = calendar.date(byAdding: .day, value: 4, to: today)!
        let later2 = calendar.date(byAdding: .day, value: 6, to: today)!
        let later3 = calendar.date(byAdding: .day, value: 8, to: today)!
        let later4 = calendar.date(byAdding: .day, value: 10, to: today)!
        
        return EventListResponse(items: [
            EventListItemResponse(
                id: "1",
                dateTime: dateString(today, hour: 18),
                subtitle: "Большая дружеская встреча по волейболу на снегу",
                price: "650",
                address: "ул. Победы, 33",
                participantCount: 12,
                type: "admin"
            ),
            EventListItemResponse(
                id: "2",
                dateTime: dateString(tomorrow, hour: 12),
                subtitle: "Тренировка в зале",
                price: "0",
                address: "ул. Центральная, 5",
                participantCount: 4,
                type: "participant"
            ),
            EventListItemResponse(
                id: "3",
                dateTime: dateString(later1, hour: 12),
                subtitle: "Командная встреча",
                price: "650",
                address: "ул. Победы, 33",
                participantCount: 12,
                type: "admin"
            ),
            EventListItemResponse(
                id: "4",
                dateTime: dateString(later2, hour: 15),
                subtitle: "Тренировка в зале",
                price: "0",
                address: "ул. Центральная, 5",
                participantCount: 12,
                type: "admin"
            ),
            EventListItemResponse(
                id: "5",
                dateTime: dateString(later3, hour: 15),
                subtitle: "Тренировка в зале",
                price: "0",
                address: "ул. Центральная, 5",
                participantCount: 2,
                type: "participant"
            ),
            EventListItemResponse(
                id: "6",
                dateTime: dateString(later4, hour: 18),
                subtitle: "Вечерняя игра",
                price: "0",
                address: "ул. Спортивная, 10",
                participantCount: 8,
                type: "participant"
            ),
            EventListItemResponse(
                id: "7",
                dateTime: dateString(today, hour: 20),
                subtitle: "Открытая тренировка для новичков",
                price: "0",
                address: "ул. Ленина, 15",
                participantCount: 6,
                type: "nobody"
            ),
            EventListItemResponse(
                id: "8",
                dateTime: dateString(tomorrow, hour: 18),
                subtitle: "Турнир 4x4",
                price: "500",
                address: "ул. Спортивная, 22",
                participantCount: 16,
                type: "nobody"
            ),
            EventListItemResponse(
                id: "9",
                dateTime: dateString(later2, hour: 12),
                subtitle: "Пляжный волейбол",
                price: "0",
                address: "пляж Городской, 1",
                participantCount: 8,
                type: "nobody"
            ),
            EventListItemResponse(
                id: "10",
                dateTime: dateString(later3, hour: 19),
                subtitle: "Дружеская встреча",
                price: "300",
                address: "ул. Мира, 45",
                participantCount: 10,
                type: "nobody"
            )
        ])
    }
    
    private func createMockEventDetails() -> EventDetailsResponse {
        let currentUserId = "current_user_id"
        
        var participants: [ParticipantResponse] = [
            ParticipantResponse(id: "1", avatarUrl: nil, name: "admin"),
            ParticipantResponse(id: "2", avatarUrl: nil, name: "leonid_smirnov"),
            ParticipantResponse(id: "3", avatarUrl: nil, name: "michel")
        ]
        
        var hosts: [ParticipantResponse] = [
            ParticipantResponse(id: "1", avatarUrl: nil, name: "admin")
        ]
        
        // Добавляем текущего пользователя в зависимости от роли
        switch userRole {
        case .viewer:
            break
        case .participant:
            participants.append(ParticipantResponse(id: currentUserId, avatarUrl: nil, name: "username"))
        case .host:
            participants.append(ParticipantResponse(id: currentUserId, avatarUrl: nil, name: "username"))
            hosts = [ParticipantResponse(id: currentUserId, avatarUrl: nil, name: "username")]
        }
        
        return EventDetailsResponse(
            title: "Дружеская встреча по волейболу на снегу",
            startDt: "2025-11-27T18:15:00",
            endDt: "2025-11-27T20:45:00",
            city: "Красноярск",
            address: "ул. Красноармейская, д. 113",
            maxParticipantCount: 12,
            price: "600",
            currency: "руб.",
            description: """
            Привет! 👋

            Игры пройдут 27 ноября с 18:15 до 20:45 по адресу Красноярск,
            ул. Красноармейская, д. 113

            Вход на территорию через КПП у арки.
            После входа — налево, подтрибунное помещение.

            Пожалуйста:
            • приходите за 30 минут до начала,
            • возьмите теплую, удобную спортивную форму и воду,
            • уровень смешанный — подойдёт всем,
            • формат игры: 3×3,
            • если есть свой мяч — можно взять, но не обязательно.

            Если не сможете прийти, заранее дайте знать.

            До встречи на снежной площадке! 🏐
            """,
            participants: participants,
            hosts: hosts,
            currentUserId: currentUserId
        )
    }
}



