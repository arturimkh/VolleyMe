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
    func didUpdateEmail(_ text: String)
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
    
    private var email = ""
    private var password = ""
    private var confirmPassword = ""
    private var state: RegisterState = .idle
    private var validationErrors: [RegisterValidationError] = []
    
    private enum Constants {
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
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            state: state,
            validationErrors: validationErrors
        )
        view?.configure(with: viewModel)
    }
    
    private func validate() -> Bool {
        validationErrors = []
        
        if email.isEmpty {
            validationErrors.append(.emailEmpty)
        } else if !isValidNickname(email) {
            validationErrors.append(.emailInvalid)
        }
        
        if password.isEmpty {
            validationErrors.append(.passwordEmpty)
        } else if !PasswordPolicy.isValid(password) {
            validationErrors.append(.passwordDoesNotMeetPolicy)
        }
        
        if password != confirmPassword {
            validationErrors.append(.passwordsDoNotMatch)
        }
        
        return validationErrors.isEmpty
    }
    
    /// Backend stores the field as `username`. We only check that the value uses Latin chars/digits/symbols
    /// and contains no whitespace; uniqueness and final format are validated server-side.
    private func isValidNickname(_ nickname: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-@]+$"#
        return nickname.range(of: regex, options: .regularExpression) != nil
    }

    private func userMessage(from error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? "Произошла ошибка. Попробуйте позже."
    }

    private func performRegister() {
        state = .loading
        updateView()
        
        Task { @MainActor in
            do {
                let response = try await service.register(email: email, password: password)
                tokenStorage.save(tokens: AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    userEmail: email
                ))
                state = .success
                updateView()
                
                try await Task.sleep(nanoseconds: UInt64(Constants.successDelay * 1_000_000_000))
                output?.registerDidFinish()
            } catch {
                state = .error(userMessage(from: error))
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
    
    func didUpdateEmail(_ text: String) {
        email = text
        if case .error = state { state = .idle }
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didUpdatePassword(_ text: String) {
        password = text
        if case .error = state { state = .idle }
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didUpdateConfirmPassword(_ text: String) {
        confirmPassword = text
        if case .error = state { state = .idle }
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
