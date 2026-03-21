//
//  MainFlowController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class MainFlowController: UINavigationController {
    
    // MARK: - Properties
    
    private let homeAssembly: IHomeAssembly
    private let eventDetailsAssembly: IEventDetailsAssembly
    private let newEventAssembly: INewEventAssembly
    
    var onLogout: (() -> Void)?
    
    // MARK: - Init
    
    init(
        homeAssembly: IHomeAssembly,
        eventDetailsAssembly: IEventDetailsAssembly,
        newEventAssembly: INewEventAssembly
    ) {
        self.homeAssembly = homeAssembly
        self.eventDetailsAssembly = eventDetailsAssembly
        self.newEventAssembly = newEventAssembly
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
        let homeVC = homeAssembly.assemble(output: self)
        setViewControllers([homeVC], animated: false)
    }
    
    private func showEventDetails(eventId: String) {
        let eventDetailsVC = eventDetailsAssembly.assemble(eventId: eventId, output: self)
        pushViewController(eventDetailsVC, animated: true)
    }
    
    private func showCreateEvent() {
        let newEventVC = newEventAssembly.assemble(output: self)
        pushViewController(newEventVC, animated: true)
    }
}

// MARK: - IHomeOutput

extension MainFlowController: IHomeOutput {
    func homeDidSelectEvent(eventId: String) {
        showEventDetails(eventId: eventId)
    }
    
    func homeDidTapCreateEvent() {
        showCreateEvent()
    }
    
    func homeDidTapFindEvents() {
        // Handled by presenter (switches tab)
    }
    
    func homeDidTapLogout() {
        onLogout?()
    }
}

// MARK: - IEventDetailsOutput

extension MainFlowController: IEventDetailsOutput {
    func eventDetailsDidRequestClose() {
        popViewController(animated: true)
    }
    
    func eventDetailsDidCancelEvent() {
        popViewController(animated: true)
    }
}

// MARK: - INewEventOutput

extension MainFlowController: INewEventOutput {
    func newEventDidFinish() {
        popViewController(animated: true)
    }
    
    func newEventDidCancel() {
        popViewController(animated: true)
    }
}
