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
}

// MARK: - Implementation

final class DependencyContainer: IDependencyContainer {
    
    // MARK: - Properties
    
    let requestProcessor: IRequestProcessor
    
    // MARK: - Init
    
    init() {
        // В реальном приложении можно переключать между Mock и Real
        #if DEBUG
        let mockProcessor = MockRequestProcessor()
        // Меняй userRole для тестирования разных состояний:
        // .viewer - просто смотрит (кнопка "Присоединиться")
        // .participant - участник (кнопка "Покинуть встречу")
        // .host - организатор (кнопки "Отменить встречу" и "Ссылка-приглашение")
        mockProcessor.userRole = .participant
        self.requestProcessor = mockProcessor
        #else
        self.requestProcessor = RequestProcessor()
        #endif
    }
}


