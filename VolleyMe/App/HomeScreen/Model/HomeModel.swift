//
//  HomeModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Response

struct PaginatedEventListResponse: Decodable {
    let nextUrl: String
    let prevUrl: String?
    let items: [EventListItemResponse]
}

struct EventListItemResponse: Decodable {
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

// MARK: - Domain Models

struct EventListItem {
    let id: String
    let dateTime: Date
    let title: String
    let price: String
    let city: String
    let address: String
    let participantsCount: Int
    let maxParticipantsCount: Int
    let role: EventParticipantRole
    let isPublic: Bool
    let imageUrls: [String]
    let currency: String
}

/// Matches OpenAPI `EventParticipantRole`: `"host"`, `"participant"`, `"nobody"`.
enum EventParticipantRole: String {
    case host
    case participant
    case nobody
}

// MARK: - Section

enum EventSection: Int, CaseIterable {
    case today
    case tomorrow
    case later
    case past
    
    var title: String {
        switch self {
        case .today: return "Сегодня"
        case .tomorrow: return "Завтра"
        case .later: return "Позднее"
        case .past: return "Ранее"
        }
    }
}

// MARK: - Tab

enum HomeTab: Int, CaseIterable {
    case myEvents
    case findEvents
    
    var title: String {
        switch self {
        case .myEvents: return "Мои встречи"
        case .findEvents: return "Найти встречу"
        }
    }
    
    var icon: String {
        switch self {
        case .myEvents: return "calendar"
        case .findEvents: return "magnifyingglass"
        }
    }
}

// MARK: - Response Mapping

extension EventListItemResponse {
    func toDomain() -> EventListItem {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: startDt)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: startDt)
        }
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = fallback.date(from: startDt)
        }
        
        return EventListItem(
            id: id,
            dateTime: date ?? Date(),
            title: title,
            price: price,
            city: city,
            address: address,
            participantsCount: participantsCount,
            maxParticipantsCount: maxParticipantsCount,
            role: EventParticipantRole(rawValue: myRole) ?? .nobody,
            isPublic: isPublic,
            imageUrls: imageUrls,
            currency: currency
        )
    }
}

extension PaginatedEventListResponse {
    func toDomain() -> [EventListItem] {
        items.map { $0.toDomain() }
    }
}
