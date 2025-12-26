//
//  EventDetailsModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - API Response Models

struct EventDetailsResponse: Codable {
    let title: String
    let startDt: String
    let endDt: String
    let city: String
    let address: String
    let maxParticipantCount: Int
    let price: String
    let currency: String
    let description: String
    let participants: [ParticipantResponse]
    let hosts: [ParticipantResponse]
    let currentUserId: String
}

struct ParticipantResponse: Codable {
    let id: String
    let avatarUrl: String?
    let name: String
}

// MARK: - Domain Models

struct EventDetails {
    let title: String
    let date: Date
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let city: String
    let address: String
    let maxParticipantCount: Int
    let price: String
    let currency: String
    let description: String
    let participants: [Participant]
    let hosts: [Participant]
    let userRole: UserRole
    let currentUserId: String
    
    var isFull: Bool {
        participants.count >= maxParticipantCount
    }
}

struct Participant {
    let id: String
    let avatarUrl: String?
    let name: String
    let isCurrentUser: Bool
}

enum UserRole {
    case viewer      // Просто смотрит
    case participant // Участник
    case host        // Организатор
}

// MARK: - Response to Domain Mapping

extension EventDetailsResponse {
    func toDomain() -> EventDetails {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        let startDate = dateFormatter.date(from: startDt) ?? Date()
        let endDate = dateFormatter.date(from: endDt) ?? Date()
        let duration = endDate.timeIntervalSince(startDate)
        
        let domainParticipants = participants.map { participant in
            Participant(
                id: participant.id,
                avatarUrl: participant.avatarUrl,
                name: participant.name,
                isCurrentUser: participant.id == currentUserId
            )
        }
        
        let domainHosts = hosts.map { host in
            Participant(
                id: host.id,
                avatarUrl: host.avatarUrl,
                name: host.name,
                isCurrentUser: host.id == currentUserId
            )
        }
        
        // Определяем роль пользователя
        let userRole: UserRole
        if hosts.contains(where: { $0.id == currentUserId }) {
            userRole = .host
        } else if participants.contains(where: { $0.id == currentUserId }) {
            userRole = .participant
        } else {
            userRole = .viewer
        }
        
        return EventDetails(
            title: title,
            date: startDate,
            startTime: startDate,
            endTime: endDate,
            duration: duration,
            city: city,
            address: address,
            maxParticipantCount: maxParticipantCount,
            price: price,
            currency: currency,
            description: description,
            participants: domainParticipants,
            hosts: domainHosts,
            userRole: userRole,
            currentUserId: currentUserId
        )
    }
}

