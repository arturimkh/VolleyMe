//
//  DependencyContainer.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - Protocol

protocol IDependencyContainer {
    var requestProcessor: IRequestProcessor { get }
    var keychainService: IKeychainService { get }
    var tokenStorage: ITokenStorage { get }
}

// MARK: - Implementation

final class DependencyContainer: IDependencyContainer {
    
    // MARK: - Properties
    
    let requestProcessor: IRequestProcessor
    let keychainService: IKeychainService
    let tokenStorage: ITokenStorage
    
    // MARK: - Init
    
    init() {
        let keychain = KeychainService()
        self.keychainService = keychain
        self.tokenStorage = TokenStorage(keychainService: keychain)
        
        #if DEBUG
        let mockProcessor = MockRequestProcessor()
        mockProcessor.userRole = .participant
        self.requestProcessor = mockProcessor
        #else
        self.requestProcessor = RequestProcessor()
        #endif
    }
}



