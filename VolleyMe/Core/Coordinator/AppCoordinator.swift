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
    private var isShowingAuth = false
    private var sessionExpiredObserver: NSObjectProtocol?
    
    // DI
    private let dependencyContainer: IDependencyContainer
    
    // MARK: - Initialization
    
    init(window: UIWindow, dependencyContainer: IDependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: .userSessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSessionExpired()
        }
    }
    
    deinit {
        if let sessionExpiredObserver {
            NotificationCenter.default.removeObserver(sessionExpiredObserver)
        }
    }
    
    // MARK: - Public Methods
    
    func start() {
        let splash = SplashViewController()
        splash.onFinished = { [weak self] in
            self?.handlePostSplash()
        }
        
        window.rootViewController = splash
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    private func setOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
    
    private func handlePostSplash() {
        if !hasSeenOnboarding {
            showOnboarding()
        } else if !dependencyContainer.tokenStorage.isAuthorized {
            showAuth()
        } else {
            showMainFlow()
        }
    }
    
    private func showOnboarding() {
        let assembly = OnboardingAssembly()
        let onboarding = assembly.assemble(output: self)
        
        transition(to: onboarding)
    }
    
    private func showAuth() {
        // Dismiss any modal that may sit on top of the current root (e.g. the
        // register flow) so the transition leaves a clean state.
        window.rootViewController?.dismiss(animated: false)
        mainFlowController = nil
        isShowingAuth = true
        
        let assembly = AuthAssembly(
            requestProcessor: dependencyContainer.requestProcessor,
            tokenStorage: dependencyContainer.tokenStorage
        )
        let auth = assembly.assemble(output: self)
        
        transition(to: auth)
    }
    
    private func handleSessionExpired() {
        // Idempotent: ignore stray notifications if the user is already on the
        // auth screen (e.g. multiple parallel 401s after a logout).
        guard !isShowingAuth else { return }
        showAuth()
    }
    
    private func transition(to viewController: UIViewController) {
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.window.rootViewController = viewController
            }
        )
    }
    
    private func showMainFlow() {
        isShowingAuth = false
        let homeAssembly = HomeAssembly(
            requestProcessor: dependencyContainer.requestProcessor,
            tokenStorage: dependencyContainer.tokenStorage,
            logoutService: dependencyContainer.logoutService
        )
        let eventDetailsAssembly = EventDetailsAssembly(
            requestProcessor: dependencyContainer.requestProcessor
        )
        let newEventAssembly = NewEventAssembly(
            requestProcessor: dependencyContainer.requestProcessor
        )
        let mainFlow = MainFlowController(
            homeAssembly: homeAssembly,
            eventDetailsAssembly: eventDetailsAssembly,
            newEventAssembly: newEventAssembly
        )
        mainFlow.onLogout = { [weak self] in
            self?.showAuth()
        }
        
        self.mainFlowController = mainFlow
        
        transition(to: mainFlow)
    }
}

// MARK: - IOnboardingOutput

extension AppCoordinator: IOnboardingOutput {
    func onboardingDidFinish() {
        setOnboardingSeen()
        showAuth()
    }
}

// MARK: - IAuthOutput

extension AppCoordinator: IAuthOutput {
    func authDidFinish() {
        showMainFlow()
    }
    
    func authDidTapRegister() {
        guard let authVC = window.rootViewController else { return }
        
        let assembly = RegisterAssembly(
            requestProcessor: dependencyContainer.requestProcessor,
            tokenStorage: dependencyContainer.tokenStorage
        )
        let registerVC = assembly.assemble(output: self)
        registerVC.modalPresentationStyle = .fullScreen
        authVC.present(registerVC, animated: true)
    }
}

// MARK: - IRegisterOutput

extension AppCoordinator: IRegisterOutput {
    func registerDidFinish() {
        window.rootViewController?.dismiss(animated: false)
        showMainFlow()
    }
    
    func registerDidTapClose() {
        window.rootViewController?.dismiss(animated: true)
    }
}
