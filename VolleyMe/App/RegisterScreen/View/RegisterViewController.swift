//
//  RegisterViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class RegisterViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 24
        static let fieldHeight: CGFloat = 52
        static let buttonHeight: CGFloat = 52
        static let fieldSpacing: CGFloat = 12
        static let animationDuration: TimeInterval = 0.25
    }
    
    // MARK: - Properties
    
    private let presenter: IRegisterPresenter
    private var isPasswordVisible = false
    private var isConfirmVisible = false
    private var formCenterYConstraint: Constraint?
    
    // MARK: - UI Elements
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новый аккаунт"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nicknameField: RegisterTextField = {
        let field = RegisterTextField(placeholder: "Никнейм", isSecure: false)
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.delegate = self
        field.addTarget(self, action: #selector(nicknameChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var passwordField: RegisterTextField = {
        let field = RegisterTextField(placeholder: "Пароль", isSecure: true)
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.delegate = self
        field.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        field.setToggleAction(target: self, action: #selector(togglePasswordVisibility))
        return field
    }()
    
    private lazy var confirmPasswordField: RegisterTextField = {
        let field = RegisterTextField(placeholder: "Повторите пароль", isSecure: true)
        field.returnKeyType = .done
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.delegate = self
        field.addTarget(self, action: #selector(confirmPasswordChanged), for: .editingChanged)
        field.setToggleAction(target: self, action: #selector(toggleConfirmVisibility))
        return field
    }()
    
    private let passwordMismatchLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
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
    
    private let formContainerView = UIView()
    
    // MARK: - Init
    
    init(presenter: IRegisterPresenter) {
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
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(formContainerView)
        
        formContainerView.addSubview(nicknameField)
        formContainerView.addSubview(passwordField)
        formContainerView.addSubview(confirmPasswordField)
        formContainerView.addSubview(passwordMismatchLabel)
        formContainerView.addSubview(submitButton)
        submitButton.addSubview(loadingIndicator)
        
        view.addSubview(successContainerView)
        successContainerView.addSubview(successImageView)
        successContainerView.addSubview(successTitleLabel)
        successContainerView.addSubview(successSubtitleLabel)
        successContainerView.addSubview(successProgressView)
        
        closeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeButton)
        }
        
        formContainerView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            formCenterYConstraint = make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-16).constraint
        }
        
        nicknameField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(Constants.fieldSpacing)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        confirmPasswordField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(Constants.fieldSpacing)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        passwordMismatchLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordMismatchLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.height.equalTo(Constants.buttonHeight)
            make.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(submitButton.titleLabel!.snp.leading).offset(-8)
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
    
    // MARK: - Success Animation
    
    private func showSuccess(title: String?, subtitle: String?) {
        successTitleLabel.text = title
        successSubtitleLabel.text = subtitle
        successContainerView.isHidden = false
        successProgressView.setProgress(0, animated: false)
        
        UIView.animate(withDuration: 0.4) {
            self.formContainerView.alpha = 0
            self.closeButton.alpha = 0
            self.titleLabel.alpha = 0
            self.successContainerView.alpha = 1
        }
        
        UIView.animate(withDuration: 1.8, delay: 0.2, options: .curveEaseInOut) {
            self.successProgressView.setProgress(1.0, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        presenter.didTapClose()
    }
    
    @objc private func nicknameChanged() {
        presenter.didUpdateNickname(nicknameField.text ?? "")
    }
    
    @objc private func passwordChanged() {
        presenter.didUpdatePassword(passwordField.text ?? "")
    }
    
    @objc private func confirmPasswordChanged() {
        presenter.didUpdateConfirmPassword(confirmPasswordField.text ?? "")
    }
    
    @objc private func submitTapped() {
        presenter.didTapSubmit()
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordField.setSecure(!isPasswordVisible)
    }
    
    @objc private func toggleConfirmVisibility() {
        isConfirmVisible.toggle()
        confirmPasswordField.setSecure(!isConfirmVisible)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let safeBottom = view.safeAreaInsets.bottom
        let keyboardInset = keyboardFrame.height - safeBottom + 16
        
        formCenterYConstraint?.update(offset: -keyboardInset)
        
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        formCenterYConstraint?.update(offset: -16)
        
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - IRegisterView

extension RegisterViewController: IRegisterView {
    
    func configure(with viewModel: RegisterViewModel) {
        nicknameField.updateState(hasError: viewModel.nicknameField.hasError)
        nicknameField.isEnabled = viewModel.nicknameField.isEnabled
        
        passwordField.updateState(hasError: viewModel.passwordField.hasError)
        passwordField.isEnabled = viewModel.passwordField.isEnabled
        
        confirmPasswordField.updateState(hasError: viewModel.confirmPasswordField.hasError)
        confirmPasswordField.isEnabled = viewModel.confirmPasswordField.isEnabled
        
        if let mismatch = viewModel.passwordMismatchError {
            passwordMismatchLabel.text = mismatch
            passwordMismatchLabel.isHidden = false
        } else {
            passwordMismatchLabel.isHidden = true
        }
        
        submitButton.setTitle(viewModel.submitButton.title, for: .normal)
        submitButton.isEnabled = viewModel.submitButton.isEnabled
        submitButton.alpha = viewModel.submitButton.isEnabled ? 1.0 : 0.6
        
        if viewModel.submitButton.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        if viewModel.showSuccessState {
            showSuccess(title: viewModel.successTitle, subtitle: viewModel.successSubtitle)
        }
    }
    
    func showWarningAlert(onConfirmed: @escaping () -> Void) {
        let alert = RegisterWarningAlertViewController()
        alert.onConfirmed = onConfirmed
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            presenter.didTapSubmit()
        }
        return true
    }
}

// MARK: - RegisterTextField

final class RegisterTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 44)
    private let floatingLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private var hasFloatingLabel = false
    
    init(placeholder: String, isSecure: Bool) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        setupStyle()
        setupFloatingLabel(placeholder: placeholder)
        if isSecure { setupToggleButton() }
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
        autocorrectionType = .no
    }
    
    private func setupFloatingLabel(placeholder: String) {
        floatingLabel.text = placeholder
        floatingLabel.font = .systemFont(ofSize: 12)
        floatingLabel.textColor = .systemGray
        floatingLabel.isHidden = true
        addSubview(floatingLabel)
    }
    
    private func setupToggleButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        toggleButton.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        toggleButton.tintColor = .systemGray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        rightView = toggleButton
        rightViewMode = .always
    }
    
    func setToggleAction(target: Any?, action: Selector) {
        toggleButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setSecure(_ secure: Bool) {
        isSecureTextEntry = secure
        let iconName = secure ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        toggleButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
    }
    
    func updateState(hasError: Bool) {
        layer.borderColor = hasError
            ? UIColor.systemRed.cgColor
            : (isFirstResponder ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor)
        floatingLabel.textColor = hasError ? .systemRed : .systemGray
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            layer.borderColor = UIColor.systemBlue.cgColor
            showFloatingLabel()
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            layer.borderColor = UIColor.systemGray4.cgColor
            if (text ?? "").isEmpty { hideFloatingLabel() }
        }
        return result
    }
    
    private func showFloatingLabel() {
        guard floatingLabel.isHidden else { return }
        floatingLabel.isHidden = false
        floatingLabel.alpha = 0
        floatingLabel.transform = CGAffineTransform(translationX: 0, y: 4)
        UIView.animate(withDuration: 0.2) {
            self.floatingLabel.alpha = 1
            self.floatingLabel.transform = .identity
        }
        self.placeholder = nil
    }
    
    private func hideFloatingLabel() {
        UIView.animate(withDuration: 0.2, animations: {
            self.floatingLabel.alpha = 0
        }) { _ in
            self.floatingLabel.isHidden = true
            self.placeholder = self.floatingLabel.text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        floatingLabel.frame = CGRect(x: 12, y: 6, width: bounds.width - 24, height: 16)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let hasText = !(text ?? "").isEmpty || isFirstResponder
        let top: CGFloat = hasText && !floatingLabel.isHidden ? 20 : 0
        return CGRect(x: 12, y: top, width: bounds.width - (rightViewMode == .always ? 52 : 24), height: bounds.height - top)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 8
        return rect
    }
}

// MARK: - RegisterWarningAlertViewController

final class RegisterWarningAlertViewController: UIViewController {
    
    var onConfirmed: (() -> Void)?
    
    private var isChecked = false
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Предупреждаем!"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Восстановление учетных данных в разработке.\n\nЧтобы не терять доступ к аккаунту, сохраните никнейм и пароль."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()
    
    private let checkboxLabel: UILabel = {
        let label = UILabel()
        label.text = "Я ознакомился(-ась) с предупреждением."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Подтвердить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray3, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.contentHorizontalAlignment = .right
        button.isEnabled = false
        button.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(dismiss_), for: .touchUpInside)
        return button
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCheckbox()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(checkboxButton)
        containerView.addSubview(checkboxLabel)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
        
        dimView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(24)
            make.size.equalTo(24)
        }
        
        checkboxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkboxButton)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(24)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(checkboxLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(28)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().inset(24)
        }
        
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dismiss_))
        dimView.addGestureRecognizer(dimTap)
    }
    
    private func updateCheckbox() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let iconName = isChecked ? "checkmark.square.fill" : "square"
        checkboxButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        checkboxButton.tintColor = isChecked ? .systemBlue : .systemGray3
        confirmButton.isEnabled = isChecked
    }
    
    @objc private func checkboxTapped() {
        isChecked.toggle()
        updateCheckbox()
    }
    
    @objc private func confirm() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirmed?()
        }
    }
    
    @objc private func dismiss_() {
        dismiss(animated: true)
    }
}
