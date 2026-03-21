//
//  HomeModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - API Response

struct EventListResponse: Codable {
    let items: [EventListItemResponse]
}

struct EventListItemResponse: Codable {
    let id: String
    let dateTime: String
    let subtitle: String
    let price: String
    let address: String
    let participantCount: Int
    let type: String
}

// MARK: - Domain Models

struct EventListItem {
    let id: String
    let dateTime: Date
    let subtitle: String
    let price: String
    let address: String
    let participantCount: Int
    let role: EventRole
}

enum EventRole: String {
    case admin
    case participant
    case nobody
}

// MARK: - Section

enum EventSection: Int, CaseIterable {
    case today
    case tomorrow
    case later
    
    var title: String {
        switch self {
        case .today: return "Сегодня"
        case .tomorrow: return "Завтра"
        case .later: return "Позднее"
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "ru_RU")
        let date = formatter.date(from: dateTime) ?? Date()
        
        return EventListItem(
            id: id,
            dateTime: date,
            subtitle: subtitle,
            price: price,
            address: address,
            participantCount: participantCount,
            role: EventRole(rawValue: type) ?? .nobody
        )
    }
}

extension EventListResponse {
    func toDomain() -> [EventListItem] {
        items.map { $0.toDomain() }
    }
}
