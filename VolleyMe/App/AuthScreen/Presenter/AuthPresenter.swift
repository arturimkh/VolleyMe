//
//  AuthPresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - View Protocol

protocol IAuthView: AnyObject {
    func configure(with viewModel: AuthViewModel)
}

// MARK: - Output Protocol

protocol IAuthOutput: AnyObject {
    func authDidFinish()
    func authDidTapRegister()
}

// MARK: - Presenter Protocol

protocol IAuthPresenter {
    func viewDidLoad()
    func didUpdateEmail(_ text: String)
    func didUpdatePassword(_ text: String)
    func didTapLogin()
    func didTapRegister()
}

// MARK: - Implementation

final class AuthPresenter {
    
    // MARK: - Properties
    
    weak var view: IAuthView?
    weak var output: IAuthOutput?
    
    private let service: IAuthService
    private let tokenStorage: ITokenStorage
    private let viewModelFactory: IAuthViewModelFactory
    
    private var email = ""
    private var password = ""
    private var state: AuthState = .idle
    private var validationErrors: [AuthValidationError] = []
    
    private enum Constants {
        static let successDelay: TimeInterval = 2.0
    }
    
    // MARK: - Init
    
    init(
        service: IAuthService,
        tokenStorage: ITokenStorage,
        viewModelFactory: IAuthViewModelFactory
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
}

// MARK: - IAuthPresenter

extension AuthPresenter: IAuthPresenter {
    
    func viewDidLoad() {
        updateView()
    }
    
    func didUpdateEmail(_ text: String) {
        email = text
        if case .error(_) = state { state = .idle }
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didUpdatePassword(_ text: String) {
        password = text
        if case .error(_) = state { state = .idle }
        if !validationErrors.isEmpty { validationErrors = [] }
        updateView()
    }
    
    func didTapLogin() {
        guard validate() else {
            updateView()
            return
        }
        
        state = .loading
        updateView()
        
        Task { @MainActor in
            do {
                let response = try await service.login(email: email, password: password)
                tokenStorage.save(tokens: AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    userEmail: email
                ))
                state = .success
                updateView()
                
                try await Task.sleep(nanoseconds: UInt64(Constants.successDelay * 1_000_000_000))
                output?.authDidFinish()
            } catch {
                state = .error(userMessage(from: error))
                updateView()
            }
        }
    }
    
    func didTapRegister() {
        output?.authDidTapRegister()
    }
}
