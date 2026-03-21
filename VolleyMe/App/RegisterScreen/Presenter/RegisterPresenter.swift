//
//  RegisterPresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - View Protocol

protocol IRegisterView: AnyObject {
    func configure(with viewModel: RegisterViewModel)
    func showWarningAlert(onConfirmed: @escaping () -> Void)
}

// MARK: - Output Protocol

protocol IRegisterOutput: AnyObject {
    func registerDidFinish()
    func registerDidTapClose()
}

// MARK: - Presenter Protocol

protocol IRegisterPresenter {
    func viewDidLoad()
    func didUpdateNickname(_ text: String)
    func didUpdatePassword(_ text: String)
    func didUpdateConfirmPassword(_ text: String)
    func didTapSubmit()
    func didTapClose()
}

// MARK: - Implementation

final class RegisterPresenter {
    
    // MARK: - Properties
    
    weak var view: IRegisterView?
    weak var output: IRegisterOutput?
    
    private let service: IRegisterService
    private let tokenStorage: ITokenStorage
    private let viewModelFactory: IRegisterViewModelFactory
    
    private var nickname = ""
    private var password = ""
    private var confirmPassword = ""
    private var state: RegisterState = .idle
    private var validationErrors: [RegisterValidationError] = []
    
    private enum Constants {
        static let minNicknameLength = 3
        static let minPasswordLength = 6
        static let successDelay: TimeInterval = 2.0
    }
    
    // MARK: - Init
    
    init(
        service: IRegisterService,
        tokenStorage: ITokenStorage,
        viewModelFactory: IRegisterViewModelFactory
    ) {
        self.service = service
        self.tokenStorage = tokenStorage
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Private
    
    private func updateView() {
        let viewModel = viewModelFactory.makeViewModel(
            nickname: nickname,
            password: password,
            confirmPassword: confirmPassword,
            state: state,
            validationErrors: validationErrors
        )
        view?.configure(with: viewModel)
    }
    
    private func validate() -> Bool {
        validationErrors = []
        
        if nickname.isEmpty {
            validationErrors.append(.nicknameEmpty)
        } else if nickname.count < Constants.minNicknameLength {
            validationErrors.append(.nicknameTooShort)
        }
        
        if password.isEmpty {
            validationErrors.append(.passwordEmpty)
        } else if password.count < Constants.minPasswordLength {
            validationErrors.append(.passwordTooShort)
        }
        
        if password != confirmPassword {
            validationErrors.append(.passwordsDoNotMatch)
        }
        
        return validationErrors.isEmpty
    }
    
    private func performRegister() {
        state = .loading
        updateView()
        
        Task { @MainActor in
            do {
                let response = try await service.register(nickname: nickname, password: password)
                tokenStorage.save(tokens: AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                ))
                state = .success
                updateView()
                
                try await Task.sleep(nanoseconds: UInt64(Constants.successDelay * 1_000_000_000))
                output?.registerDidFinish()
            } catch let error as RegisterError {
                state = .error(error.localizedDescription ?? "Ошибка регистрации")
                updateView()
            } catch {
                state = .error("Произошла ошибка. Попробуйте позже.")
                updateView()
            }
        }
    }
}

// MARK: - IRegisterPresenter

extension RegisterPresenter: IRegisterPresenter {
    
    func viewDidLoad() {
        updateView()
    }
    
    func didUpdateNickname(_ text: String) {
        nickname = text
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didUpdatePassword(_ text: String) {
        password = text
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didUpdateConfirmPassword(_ text: String) {
        confirmPassword = text
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didTapSubmit() {
        guard validate() else {
            updateView()
            return
        }
        view?.showWarningAlert { [weak self] in
            self?.performRegister()
        }
    }
    
    func didTapClose() {
        output?.registerDidTapClose()
    }
}
