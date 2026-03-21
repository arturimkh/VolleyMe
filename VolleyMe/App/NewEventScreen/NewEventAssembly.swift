//
//  NewEventAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit

// MARK: - Protocol

protocol INewEventAssembly {
    func assemble(output: INewEventOutput?) -> UIViewController
}

// MARK: - Implementation

final class NewEventAssembly: INewEventAssembly {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    // MARK: - INewEventAssembly
    
    func assemble(output: INewEventOutput?) -> UIViewController {
        let service = NewEventService(requestProcessor: requestProcessor)
        let viewModelFactory = NewEventViewModelFactory()
        
        let presenter = NewEventPresenter(
            service: service,
            viewModelFactory: viewModelFactory
        )
        
        let viewController = NewEventViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}
