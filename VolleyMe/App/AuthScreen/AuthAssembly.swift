//
//  AuthAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IAuthAssembly {
    func assemble(output: IAuthOutput?) -> UIViewController
}

// MARK: - Implementation

final class AuthAssembly: IAuthAssembly {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    private let tokenStorage: ITokenStorage
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor, tokenStorage: ITokenStorage) {
        self.requestProcessor = requestProcessor
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - IAuthAssembly
    
    func assemble(output: IAuthOutput?) -> UIViewController {
        let service = AuthService(requestProcessor: requestProcessor)
        let viewModelFactory = AuthViewModelFactory()
        
        let presenter = AuthPresenter(
            service: service,
            tokenStorage: tokenStorage,
            viewModelFactory: viewModelFactory
        )
        
        let viewController = AuthViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}
