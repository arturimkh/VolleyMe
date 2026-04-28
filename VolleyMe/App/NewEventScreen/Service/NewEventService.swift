//
//  NewEventService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import Foundation

// MARK: - Protocol

protocol INewEventService {
    func createEvent(dto: CreateEventDTO) async throws
}

// MARK: - Implementation

final class NewEventService: INewEventService {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    private let encoder: JSONEncoder
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - INewEventService
    
    func createEvent(dto: CreateEventDTO) async throws {
        let body = try encoder.encode(dto)
        try await requestProcessor.post("/events/", body: body)
    }
}
