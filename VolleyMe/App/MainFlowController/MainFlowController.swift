//
//  MainFlowController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class MainFlowController: UINavigationController {
    
    // MARK: - Properties
    
    private let eventDetailsAssembly: IEventDetailsAssembly
    
    // MARK: - Init
    
    init(eventDetailsAssembly: IEventDetailsAssembly) {
        self.eventDetailsAssembly = eventDetailsAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootViewController()
    }
    
    // MARK: - Private Methods
    
    private func setupRootViewController() {
        // Показываем экран Event Details с тестовым eventId
        let eventDetailsVC = eventDetailsAssembly.assemble(eventId: "test_event_123", output: self)
        setViewControllers([eventDetailsVC], animated: false)
    }
}

// MARK: - IEventDetailsOutput

extension MainFlowController: IEventDetailsOutput {
    func eventDetailsDidRequestClose() {
        // В реальном приложении здесь будет переход назад
        print("Close requested")
    }
    
    func eventDetailsDidCancelEvent() {
        // В реальном приложении здесь будет обработка отмены события
        print("Event cancelled")
    }
}


