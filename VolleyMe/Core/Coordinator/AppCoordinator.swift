//
//  AppCoordinator.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

/// Главный координатор приложения
final class AppCoordinator {
    
    // MARK: - Properties
    
    private let window: UIWindow
    private var mainFlowController: MainFlowController?
    
    // DI
    private let dependencyContainer: IDependencyContainer
    
    // MARK: - Initialization
    
    init(window: UIWindow, dependencyContainer: IDependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Public Methods
    
    func start() {
        let eventDetailsAssembly = EventDetailsAssembly(
            requestProcessor: dependencyContainer.requestProcessor
        )
        let mainFlow = MainFlowController(eventDetailsAssembly: eventDetailsAssembly)
        
        self.mainFlowController = mainFlow
        
        window.rootViewController = mainFlow
        window.makeKeyAndVisible()
    }
}
