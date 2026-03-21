//
//  HomeService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Protocol

protocol IHomeService {
    func fetchEvents() async throws -> [EventListItem]
}

// MARK: - Implementation

final class HomeService: IHomeService {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    // MARK: - IHomeService
    
    func fetchEvents() async throws -> [EventListItem] {
        let response: EventListResponse = try await requestProcessor.fetch("/events")
        return response.toDomain()
    }
}
