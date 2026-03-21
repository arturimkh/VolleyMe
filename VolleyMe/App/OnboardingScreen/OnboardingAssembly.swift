//
//  OnboardingAssembly.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IOnboardingAssembly {
    func assemble(output: IOnboardingOutput?) -> UIViewController
}

// MARK: - Implementation

final class OnboardingAssembly: IOnboardingAssembly {
    
    // MARK: - IOnboardingAssembly
    
    func assemble(output: IOnboardingOutput?) -> UIViewController {
        let viewModelFactory = OnboardingViewModelFactory()
        let presenter = OnboardingPresenter(viewModelFactory: viewModelFactory)
        let viewController = OnboardingViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.output = output
        
        return viewController
    }
}
