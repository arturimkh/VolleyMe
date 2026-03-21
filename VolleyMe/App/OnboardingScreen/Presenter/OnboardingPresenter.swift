//
//  OnboardingPresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - View Protocol

protocol IOnboardingView: AnyObject {
    func configure(with viewModel: OnboardingViewModel, animated: Bool, direction: Int)
    func setupDots(count: Int)
}

// MARK: - Output Protocol

protocol IOnboardingOutput: AnyObject {
    func onboardingDidFinish()
}

// MARK: - Presenter Protocol

protocol IOnboardingPresenter {
    func viewDidLoad()
    func didTapAction()
    func didTapBack()
    func didTapSkip()
}

// MARK: - Implementation

final class OnboardingPresenter {
    
    // MARK: - Properties
    
    weak var view: IOnboardingView?
    weak var output: IOnboardingOutput?
    
    private let viewModelFactory: IOnboardingViewModelFactory
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Организуйте\nоффлайн-встречу",
            subtitle: "Назначьте время и место встречи, укажите\nкол-во участников, стоимость участия и\nдругие детали.",
            isLastPage: false,
            placeholderIndex: 1
        ),
        OnboardingPage(
            title: "Отправьте\nссылку-приглашение",
            subtitle: "Пригласите друзей, используйте\nмессенджеры и социальные сети,\nчтобы привлечь больше людей.",
            isLastPage: false,
            placeholderIndex: 2
        ),
        OnboardingPage(
            title: "Ваши встречи\nна главном экране",
            subtitle: "Список запланированных встреч,\nв которых вы участвуете,\nили которые вы организовали.",
            isLastPage: false,
            placeholderIndex: 3
        ),
        OnboardingPage(
            title: "Находите новые\nзнакомства",
            subtitle: "Организованные другими людьми встечи –\nв соседней вкладке.",
            isLastPage: false,
            placeholderIndex: 4
        ),
        OnboardingPage(
            title: "Создавайте и\nприсоединяйтесь",
            subtitle: "Узнайте все детали заранее,\nприсоединитесь по ссылке-приглашению.",
            isLastPage: true,
            placeholderIndex: 5
        ),
    ]
    
    private var currentIndex = 0
    
    // MARK: - Init
    
    init(viewModelFactory: IOnboardingViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Private
    
    private func updateView(animated: Bool, direction: Int) {
        let viewModel = viewModelFactory.makeViewModel(
            page: pages[currentIndex],
            currentIndex: currentIndex,
            totalPages: pages.count
        )
        view?.configure(with: viewModel, animated: animated, direction: direction)
    }
}

// MARK: - IOnboardingPresenter

extension OnboardingPresenter: IOnboardingPresenter {
    
    func viewDidLoad() {
        view?.setupDots(count: pages.count)
        updateView(animated: false, direction: 0)
    }
    
    func didTapAction() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
            updateView(animated: true, direction: 1)
        } else {
            output?.onboardingDidFinish()
        }
    }
    
    func didTapBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateView(animated: true, direction: -1)
    }
    
    func didTapSkip() {
        output?.onboardingDidFinish()
    }
}
