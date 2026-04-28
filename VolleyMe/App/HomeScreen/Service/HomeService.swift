//
//  HomeService.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Protocol

protocol IHomeService {
    func fetchEvents(onlyMine: Bool) async throws -> [EventListItem]
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
    
    func fetchEvents(onlyMine: Bool) async throws -> [EventListItem] {
        let endpoint = onlyMine ? "/events/?only_my_events=true" : "/events/"
        let response: PaginatedEventListResponse = try await requestProcessor.fetch(endpoint)
        return response.toDomain()
    }
}
