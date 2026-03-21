//
//  EventDetailsAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

// MARK: - Protocol

protocol IEventDetailsAssembly {
    func assemble(eventId: String, output: IEventDetailsOutput?) -> UIViewController
}

// MARK: - Implementation

final class EventDetailsAssembly: IEventDetailsAssembly {
    
    // MARK: - Properties
    
    private let requestProcessor: IRequestProcessor
    
    // MARK: - Init
    
    init(requestProcessor: IRequestProcessor) {
        self.requestProcessor = requestProcessor
    }
    
    // MARK: - IEventDetailsAssembly
    
    func assemble(eventId: String, output: IEventDetailsOutput?) -> UIViewController {
        let service = EventDetailsService(requestProcessor: requestProcessor)
        let viewModelFactory = EventDetailsViewModelFactory()
        
        let presenter = EventDetailsPresenter(
            eventId: eventId,
            service: service,
            viewModelFactory: viewModelFactory
        )
        
        let viewController = EventDetailsViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}



