//
//  LogoutService.swift
//  VolleyMe
//

import Foundation

// MARK: - Protocol

protocol ILogoutService {
    /// Calls `POST /auth/logout/` with the current access token.
    /// Throws on network/server errors so the caller can decide whether to
    /// surface them or proceed with a local cleanup anyway.
    func logout() async throws
}

// MARK: - Implementation

final class LogoutService: ILogoutService {

    private let requestProcessor: IRequestProcessor

    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }

    func logout() async throws {
        try await requestProcessor.post("/auth/logout/", body: nil)
    }
}
