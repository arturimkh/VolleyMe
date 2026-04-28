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
    var logoutService: ILogoutService { get }
}

// MARK: - Implementation

final class DependencyContainer: IDependencyContainer {
    
    // MARK: - Properties
    
    let requestProcessor: IRequestProcessor
    let keychainService: IKeychainService
    let tokenStorage: ITokenStorage
    let logoutService: ILogoutService
    
    // MARK: - Init
    
    init() {
        let keychain = KeychainService()
        self.keychainService = keychain
        self.tokenStorage = TokenStorage(keychainService: keychain)
        
        let processor: IRequestProcessor
        #if DEBUG
        processor = RequestProcessor(
            baseURL: "https://volleyme.ru",
            tokenStorage: self.tokenStorage
        )
        #else
        processor = RequestProcessor(tokenStorage: self.tokenStorage)
        #endif
        self.requestProcessor = processor
        self.logoutService = LogoutService(requestProcessor: processor)
    }
}



