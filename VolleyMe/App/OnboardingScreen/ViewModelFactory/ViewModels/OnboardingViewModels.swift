//
//  OnboardingViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Main ViewModel

struct OnboardingViewModel {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let image: UIImage?
    let placeholderText: String
    let placeholderColor: UIColor
    let showBackButton: Bool
    let currentPage: Int
    let totalPages: Int
}
