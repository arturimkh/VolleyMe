//
//  EventDetailsModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - API Response Models

struct EventDetailsResponse: Decodable {
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
    let participants: [ParticipantResponse]
    let hosts: [ParticipantResponse]
    let isPublic: Bool
    let imageUrls: [String]
    let country: String
    let gameType: Int
    let formatType: Int
}

struct ParticipantResponse: Decodable {
    let id: String
    let avatarUrl: String?
    let name: String?
}

// MARK: - Domain Models

struct EventDetails {
    let id: String
    let title: String
    let date: Date
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let city: String
    let address: String
    let participantsCount: Int
    let maxParticipantsCount: Int
    let price: String
    let currency: String
    let description: String
    let participants: [Participant]
    let hosts: [Participant]
    let userRole: UserRole
    let isPublic: Bool
    let imageUrls: [String]
    
    var isFull: Bool {
        participantsCount >= maxParticipantsCount
    }
}

struct Participant {
    let id: String
    let avatarUrl: String?
    let name: String?
}

enum UserRole {
    case viewer
    case participant
    case host
}

extension EventParticipantRole {
    var userRole: UserRole {
        switch self {
        case .host: return .host
        case .participant: return .participant
        case .nobody: return .viewer
        }
    }
}

// MARK: - Response to Domain Mapping

extension EventDetailsResponse {
    func toDomain() -> EventDetails {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var startDate = formatter.date(from: startDt)
        if startDate == nil {
            formatter.formatOptions = [.withInternetDateTime]
            startDate = formatter.date(from: startDt)
        }
        var endDate = formatter.date(from: endDt)
        if endDate == nil {
            formatter.formatOptions = [.withInternetDateTime]
            endDate = formatter.date(from: endDt)
        }
        
        let start = startDate ?? Date()
        let end = endDate ?? Date()
        let duration = end.timeIntervalSince(start)
        
        let apiRole = EventParticipantRole(rawValue: myRole) ?? .nobody
        let userRole = apiRole.userRole
        
        let domainParticipants = participants.map {
            Participant(id: $0.id, avatarUrl: $0.avatarUrl, name: $0.name)
        }
        let domainHosts = hosts.map {
            Participant(id: $0.id, avatarUrl: $0.avatarUrl, name: $0.name)
        }
        
        return EventDetails(
            id: id,
            title: title,
            date: start,
            startTime: start,
            endTime: end,
            duration: duration,
            city: city,
            address: address,
            participantsCount: participantsCount,
            maxParticipantsCount: maxParticipantsCount,
            price: price,
            currency: currency,
            description: description,
            participants: domainParticipants,
            hosts: domainHosts,
            userRole: userRole,
            isPublic: isPublic,
            imageUrls: imageUrls
        )
    }
}
