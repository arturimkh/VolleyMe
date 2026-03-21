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
    func didUpdateNickname(_ text: String)
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
    
    private var nickname = ""
    private var password = ""
    private var state: AuthState = .idle
    private var validationErrors: [AuthValidationError] = []
    
    private enum Constants {
        static let minNicknameLength = 3
        static let minPasswordLength = 6
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
            nickname: nickname,
            password: password,
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
        
        return validationErrors.isEmpty
    }
}

// MARK: - IAuthPresenter

extension AuthPresenter: IAuthPresenter {
    
    func viewDidLoad() {
        updateView()
    }
    
    func didUpdateNickname(_ text: String) {
        nickname = text
        if state == .error("") || !validationErrors.isEmpty {
            state = .idle
            validationErrors = []
        }
        updateView()
    }
    
    func didUpdatePassword(_ text: String) {
        password = text
        if state == .error("") || !validationErrors.isEmpty {
            state = .idle
            validationErrors = []
        }
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
                let response = try await service.login(nickname: nickname, password: password)
                tokenStorage.save(tokens: AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                ))
                state = .success
                updateView()
                
                try await Task.sleep(nanoseconds: UInt64(Constants.successDelay * 1_000_000_000))
                output?.authDidFinish()
            } catch let error as AuthError {
                state = .error(error.localizedDescription ?? "Ошибка авторизации")
                updateView()
            } catch {
                state = .error("Произошла ошибка. Попробуйте позже.")
                updateView()
            }
        }
    }
    
    func didTapRegister() {
        output?.authDidTapRegister()
    }
}
