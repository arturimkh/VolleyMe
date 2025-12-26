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
    private let requestProcessor: IRequestProcessor
    
    // MARK: - Initialization
    
    init(window: UIWindow, requestProcessor: IRequestProcessor = MockRequestProcessor()) {
        self.window = window
        self.requestProcessor = requestProcessor
        
        // Настраиваем мок для демонстрации разных состояний
        if let mockProcessor = requestProcessor as? MockRequestProcessor {
            // Меняй userRole для тестирования разных состояний:
            // .viewer - просто смотрит (кнопка "Присоединиться")
            // .participant - участник (кнопка "Покинуть встречу")
            // .host - организатор (кнопки "Отменить встречу" и "Ссылка-приглашение")
            mockProcessor.userRole = .participant
        }
    }
    
    // MARK: - Public Methods
    
    func start() {
        let eventDetailsAssembly = EventDetailsAssembly(requestProcessor: requestProcessor)
        let mainFlow = MainFlowController(eventDetailsAssembly: eventDetailsAssembly)
        
        self.mainFlowController = mainFlow
        
        window.rootViewController = mainFlow
        window.makeKeyAndVisible()
    }
}
