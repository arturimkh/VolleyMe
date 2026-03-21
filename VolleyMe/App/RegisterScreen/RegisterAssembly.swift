//
//  RegisterAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IRegisterAssembly {
    func assemble(output: IRegisterOutput?) -> UIViewController
}

// MARK: - Implementation

final class RegisterAssembly: IRegisterAssembly {
    
    private let requestProcessor: IRequestProcessor
    private let tokenStorage: ITokenStorage
    
    init(requestProcessor: IRequestProcessor, tokenStorage: ITokenStorage) {
        self.requestProcessor = requestProcessor
        self.tokenStorage = tokenStorage
    }
    
    func assemble(output: IRegisterOutput?) -> UIViewController {
        let service = RegisterService(requestProcessor: requestProcessor)
        let viewModelFactory = RegisterViewModelFactory()
        
        let presenter = RegisterPresenter(
            service: service,
            tokenStorage: tokenStorage,
            viewModelFactory: viewModelFactory
        )
        
        let viewController = RegisterViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}
