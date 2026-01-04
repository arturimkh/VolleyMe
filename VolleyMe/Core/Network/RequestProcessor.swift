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
        
        if endpoint.contains("/event/") {
            let mockData = createMockEventDetails()
            let data = try JSONEncoder().encode(mockData)
            return try decoder.decode(T.self, from: data)
        }
        
        throw NetworkError.noData
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 сек
        
        if shouldFail {
            throw NetworkError.serverError(500)
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
    }
    
    // MARK: - Mock Data
    
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


