//
//  Coordinator.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

/// Протокол для навигации из экрана
protocol CoordinatorOutput: AnyObject {}

/// Базовый FlowController для навигации
class FlowController: UINavigationController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootViewController()
    }
    
    // MARK: - Methods to Override
    
    /// Переопределить для установки начального экрана
    func setupRootViewController() {
        // Override in subclass
    }
}
