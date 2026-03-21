//
//  AuthViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 24
        static let fieldHeight: CGFloat = 52
        static let fieldCornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 52
        static let fieldSpacing: CGFloat = 16
        static let errorBannerHeight: CGFloat = 44
    }
    
    // MARK: - Properties
    
    private let presenter: IAuthPresenter
    private var isPasswordVisible = false
    private var formCenterYConstraint: Constraint?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let errorBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let errorBannerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nicknameField: AuthTextField = {
        let field = AuthTextField()
        field.placeholder = "Никнейм"
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.delegate = self
        field.addTarget(self, action: #selector(nicknameChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var passwordField: AuthTextField = {
        let field = AuthTextField()
        field.placeholder = "Пароль"
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.delegate = self
        field.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        field.rightViewMode = .always
        field.rightView = makeTogglePasswordButton()
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()
    
    // Success state
    private let successContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private let successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AuthLoading")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let successTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let successSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let successProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .systemGray5
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    // Form container
    private let formContainerView = UIView()
    
    // MARK: - Init
    
    init(presenter: IAuthPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismiss()
        setupKeyboardObservers()
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(formContainerView)
        formContainerView.addSubview(titleLabel)
        formContainerView.addSubview(errorBannerView)
        errorBannerView.addSubview(errorBannerLabel)
        formContainerView.addSubview(nicknameField)
        formContainerView.addSubview(passwordField)
        formContainerView.addSubview(loginButton)
        loginButton.addSubview(loadingIndicator)
        formContainerView.addSubview(registerButton)
        
        view.addSubview(successContainerView)
        successContainerView.addSubview(successImageView)
        successContainerView.addSubview(successTitleLabel)
        successContainerView.addSubview(successSubtitleLabel)
        successContainerView.addSubview(successProgressView)
        
        formContainerView.snp.makeConstraints { make in
            formCenterYConstraint = make.centerY.equalToSuperview().offset(-40).constraint
            make.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        errorBannerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.errorBannerHeight)
        }
        
        errorBannerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        nicknameField.snp.makeConstraints { make in
            make.top.equalTo(errorBannerView.snp.bottom).offset(Constants.fieldSpacing)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(Constants.fieldSpacing)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(loginButton.titleLabel!.snp.leading).offset(-8)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Success
        successContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        successImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }
        
        successTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        successSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(successTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        successProgressView.snp.makeConstraints { make in
            make.top.equalTo(successSubtitleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(4)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func makeTogglePasswordButton() -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func nicknameChanged() {
        presenter.didUpdateNickname(nicknameField.text ?? "")
    }
    
    @objc private func passwordChanged() {
        presenter.didUpdatePassword(passwordField.text ?? "")
    }
    
    @objc private func loginTapped() {
        presenter.didTapLogin()
    }
    
    @objc private func registerTapped() {
        presenter.didTapRegister()
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordField.isSecureTextEntry = !isPasswordVisible
        
        let iconName = isPasswordVisible ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        (passwordField.rightView as? UIButton)?.setImage(
            UIImage(systemName: iconName, withConfiguration: config), for: .normal
        )
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let keyboardHeight = keyboardFrame.height
        let viewHeight = view.bounds.height
        let formHeight = formContainerView.bounds.height
        
        // Доступное пространство над клавиатурой, центрируем форму в нём со смещением вверх
        let availableHeight = viewHeight - keyboardHeight
        let targetCenterY = availableHeight / 2
        let currentCenterY = viewHeight / 2
        let offset = targetCenterY - currentCenterY - (formHeight > availableHeight - 32 ? 16 : 0)
        
        formCenterYConstraint?.update(offset: offset)
        
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        formCenterYConstraint?.update(offset: -40)
        
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Success Animation
    
    private func showSuccess(title: String?, subtitle: String?) {
        successTitleLabel.text = title
        successSubtitleLabel.text = subtitle
        successContainerView.isHidden = false
        successProgressView.setProgress(0, animated: false)
        
        UIView.animate(withDuration: 0.4) {
            self.formContainerView.alpha = 0
            self.successContainerView.alpha = 1
        }
        
        UIView.animate(withDuration: 1.8, delay: 0.2, options: .curveEaseInOut) {
            self.successProgressView.setProgress(1.0, animated: true)
        }
    }
}

// MARK: - IAuthView

extension AuthViewController: IAuthView {
    
    func configure(with viewModel: AuthViewModel) {
        titleLabel.text = viewModel.title
        
        nicknameField.updateState(hasError: viewModel.nicknameField.hasError)
        nicknameField.isEnabled = viewModel.nicknameField.isEnabled
        
        passwordField.updateState(hasError: viewModel.passwordField.hasError)
        passwordField.isEnabled = viewModel.passwordField.isEnabled
        
        loginButton.setTitle(viewModel.loginButton.title, for: .normal)
        loginButton.isEnabled = viewModel.loginButton.isEnabled
        loginButton.alpha = viewModel.loginButton.isEnabled ? 1.0 : 0.6
        
        if viewModel.loginButton.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        registerButton.setTitle(viewModel.registerButtonTitle, for: .normal)
        
        if let error = viewModel.errorMessage {
            errorBannerLabel.text = error
            errorBannerView.isHidden = false
        } else {
            errorBannerView.isHidden = true
        }
        
        if viewModel.showSuccessState {
            showSuccess(title: viewModel.successTitle, subtitle: viewModel.successSubtitle)
        }
    }
}

// MARK: - UITextFieldDelegate

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            presenter.didTapLogin()
        }
        return true
    }
}

// MARK: - AuthTextField

private final class AuthTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 44)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        borderStyle = .none
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        font = .systemFont(ofSize: 16)
        textColor = .label
    }
    
    func updateState(hasError: Bool) {
        layer.borderColor = hasError
            ? UIColor.systemRed.cgColor
            : UIColor.systemGray4.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 8
        return rect
    }
}
