//
//  EventDetailsService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - Protocol

protocol IEventDetailsService {
    func fetchEventDetails(eventId: String) async throws -> EventDetails
    func joinEvent(eventId: String) async throws
    func leaveEvent(eventId: String) async throws
    func cancelEvent(eventId: String) async throws
}

// MARK: - Implementation

final class EventDetailsService: IEventDetailsService {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    // MARK: - IEventDetailsService
    
    func fetchEventDetails(eventId: String) async throws -> EventDetails {
        let response: EventDetailsResponse = try await requestProcessor.fetch("/event/\(eventId)")
        return response.toDomain()
    }
    
    func joinEvent(eventId: String) async throws {
        try await requestProcessor.post("/event/join/\(eventId)", body: nil)
    }
    
    func leaveEvent(eventId: String) async throws {
        try await requestProcessor.post("/event/leave/\(eventId)", body: nil)
    }
    
    func cancelEvent(eventId: String) async throws {
        try await requestProcessor.post("/event/cancel/\(eventId)", body: nil)
    }
}

