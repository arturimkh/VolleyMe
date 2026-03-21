//
//  HomeAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IHomeAssembly {
    func assemble(output: IHomeOutput?) -> UIViewController
}

// MARK: - Implementation

final class HomeAssembly: IHomeAssembly {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    private let tokenStorage: ITokenStorage
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor, tokenStorage: ITokenStorage) {
        self.requestProcessor = requestProcessor
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - IHomeAssembly
    
    func assemble(output: IHomeOutput?) -> UIViewController {
        let service = HomeService(requestProcessor: requestProcessor)
        let viewModelFactory = HomeViewModelFactory()
        
        let presenter = HomePresenter(
            service: service,
            tokenStorage: tokenStorage,
            viewModelFactory: viewModelFactory
        )
        
        let viewController = HomeViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}
