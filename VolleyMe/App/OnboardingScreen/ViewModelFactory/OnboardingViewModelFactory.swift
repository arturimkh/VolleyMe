//
//  OnboardingViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IOnboardingViewModelFactory {
    func makeViewModel(page: OnboardingPage, currentIndex: Int, totalPages: Int) -> OnboardingViewModel
}

// MARK: - Implementation

final class OnboardingViewModelFactory: IOnboardingViewModelFactory {
    
    // MARK: - Constants
    
    private let placeholderColors: [UIColor] = [
        UIColor.systemBlue.withAlphaComponent(0.06),
        UIColor.systemIndigo.withAlphaComponent(0.06),
        UIColor.systemGreen.withAlphaComponent(0.06),
        UIColor.systemOrange.withAlphaComponent(0.06),
        UIColor.systemPurple.withAlphaComponent(0.06),
    ]
    
    // MARK: - IOnboardingViewModelFactory
    
    func makeViewModel(page: OnboardingPage, currentIndex: Int, totalPages: Int) -> OnboardingViewModel {
        let colorIndex = currentIndex % placeholderColors.count
        
        return OnboardingViewModel(
            title: page.title,
            subtitle: page.subtitle,
            buttonTitle: page.isLastPage ? "Перейти ко входу" : "Далее",
            placeholderText: "Скриншот \(page.placeholderIndex)",
            placeholderColor: placeholderColors[colorIndex],
            showBackButton: currentIndex > 0,
            currentPage: currentIndex,
            totalPages: totalPages
        )
    }
}
