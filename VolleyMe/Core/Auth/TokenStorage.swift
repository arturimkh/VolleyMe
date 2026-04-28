//
//  TokenStorage.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - Token Model

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let userEmail: String?
    
    var displayEmail: String? {
        userEmail ?? jwtStringClaim(named: "email") ?? jwtStringClaim(named: "username")
    }
    
    private func jwtStringClaim(named key: String) -> String? {
        let segments = accessToken.split(separator: ".")
        guard segments.count > 1 else { return nil }
        
        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = payload.count % 4
        if padding > 0 {
            payload += String(repeating: "=", count: 4 - padding)
        }
        
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let value = json[key] as? String,
              value.contains("@")
        else {
            return nil
        }
        return value
    }
}

// MARK: - Protocol

protocol ITokenStorage {
    var tokens: AuthTokens? { get }
    var isAuthorized: Bool { get }
    func save(tokens: AuthTokens)
    func clear()
}

// MARK: - Implementation

final class TokenStorage: ITokenStorage {
    
    // MARK: - Constants
    
    private enum Keys {
        static let authTokens = "auth_tokens"
    }
    
    // MARK: - Properties
    
    private let keychainService: IKeychainService
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var cachedTokens: AuthTokens?
    
    var tokens: AuthTokens? {
        if let cached = cachedTokens { return cached }
        guard let data = keychainService.load(for: Keys.authTokens),
              let decoded = try? decoder.decode(AuthTokens.self, from: data)
        else { return nil }
        cachedTokens = decoded
        return decoded
    }
    
    var isAuthorized: Bool {
        tokens != nil
    }
    
    // MARK: - Init
    
    init(keychainService: IKeychainService) {
        self.keychainService = keychainService
    }
    
    // MARK: - ITokenStorage
    
    func save(tokens: AuthTokens) {
        guard let data = try? encoder.encode(tokens) else { return }
        keychainService.save(data, for: Keys.authTokens)
        cachedTokens = tokens
    }
    
    func clear() {
        keychainService.delete(for: Keys.authTokens)
        cachedTokens = nil
    }
}
