//
//  CustomAlertViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

final class CustomAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AlertViewModel
    private var isCheckboxChecked = false
    
    var onCheckboxChanged: ((Bool) -> Void)?
    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var checkboxStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()
    
    private let checkboxLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: AlertViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configure() {
        // Title
        titleLabel.text = viewModel.title
        stackView.addArrangedSubview(titleLabel)
        
        // Message
        if let message = viewModel.message {
            messageLabel.text = message
            stackView.addArrangedSubview(messageLabel)
        }
        
        // Checkbox
        if let checkboxText = viewModel.checkboxText {
            checkboxLabel.text = checkboxText
            checkboxStackView.addArrangedSubview(checkboxButton)
            checkboxStackView.addArrangedSubview(checkboxLabel)
            stackView.addArrangedSubview(checkboxStackView)
        }
        
        // Spacer
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.height.equalTo(8)
        }
        stackView.addArrangedSubview(spacer)
        
        // Primary Button
        primaryButton.setTitle(viewModel.primaryAction.title, for: .normal)
        updatePrimaryButtonState()
        stackView.addArrangedSubview(primaryButton)
        
        // Secondary Button
        if let secondary = viewModel.secondaryAction {
            secondaryButton.setTitle(secondary.title, for: .normal)
            stackView.addArrangedSubview(secondaryButton)
        }
        
        // Cancel Button
        cancelButton.setTitle(viewModel.cancelAction.title, for: .normal)
        stackView.addArrangedSubview(cancelButton)
    }
    
    private func updatePrimaryButtonState() {
        let hasCheckbox = viewModel.checkboxText != nil
        let isEnabled = hasCheckbox ? isCheckboxChecked : viewModel.primaryAction.isEnabled
        
        primaryButton.isEnabled = isEnabled
        
        switch viewModel.primaryAction.style {
        case .destructive:
            primaryButton.setTitleColor(isEnabled ? .systemRed : .systemGray, for: .normal)
        case .default:
            primaryButton.setTitleColor(isEnabled ? UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0) : .systemGray, for: .normal)
        case .cancel:
            primaryButton.setTitleColor(.systemGray, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func checkboxTapped() {
        isCheckboxChecked.toggle()
        checkboxButton.isSelected = isCheckboxChecked
        updatePrimaryButtonState()
        onCheckboxChanged?(isCheckboxChecked)
    }
    
    @objc private func primaryTapped() {
        onPrimaryAction?()
    }
    
    @objc private func secondaryTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onSecondaryAction?()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancelAction?()
        }
    }
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}
