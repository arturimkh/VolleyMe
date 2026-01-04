//
//  EventActionButtonView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventActionButtonView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let buttonHeight: CGFloat = 44
        static let buttonCornerRadius: CGFloat = 22
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - UI Elements
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var secondaryButtonBottomConstraint: NSLayoutConstraint?
    private var primaryButtonBottomConstraint: NSLayoutConstraint?
    
    var onPrimaryTapped: (() -> Void)?
    var onSecondaryTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(topSeparator)
        addSubview(primaryButton)
        addSubview(secondaryButton)
        
        primaryButtonBottomConstraint = primaryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        secondaryButtonBottomConstraint = secondaryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            primaryButton.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 8),
            primaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            primaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            primaryButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            
            secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 8),
            secondaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            secondaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            secondaryButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        primaryButtonBottomConstraint?.isActive = true
        
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(primary: ActionButtonViewModel, secondary: ActionButtonViewModel?) {
        configurePrimaryButton(with: primary)
        configureSecondaryButton(with: secondary)
    }
    
    private func configurePrimaryButton(with viewModel: ActionButtonViewModel) {
        primaryButton.setTitle(viewModel.title, for: .normal)
        primaryButton.isEnabled = viewModel.isEnabled
        primaryButton.layer.borderWidth = 0
        
        switch viewModel.style {
        case .primary:
            primaryButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            primaryButton.setTitleColor(.white, for: .normal)
        case .secondary:
            primaryButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
            primaryButton.setTitleColor(.white, for: .normal)
        case .destructive:
            primaryButton.backgroundColor = .clear
            primaryButton.setTitleColor(.systemRed, for: .normal)
            primaryButton.layer.borderWidth = 1
            primaryButton.layer.borderColor = UIColor.systemRed.cgColor
        case .disabled:
            primaryButton.backgroundColor = .systemGray5
            primaryButton.setTitleColor(.systemGray, for: .normal)
        }
    }
    
    private func configureSecondaryButton(with viewModel: ActionButtonViewModel?) {
        guard let viewModel = viewModel else {
            secondaryButton.isHidden = true
            primaryButtonBottomConstraint?.isActive = true
            secondaryButtonBottomConstraint?.isActive = false
            return
        }
        
        secondaryButton.isHidden = false
        secondaryButton.setTitle(viewModel.title, for: .normal)
        
        if let icon = viewModel.icon {
            secondaryButton.setImage(icon, for: .normal)
            secondaryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        
        secondaryButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        secondaryButton.setTitleColor(.white, for: .normal)
        secondaryButton.tintColor = .white
        
        primaryButtonBottomConstraint?.isActive = false
        secondaryButtonBottomConstraint?.isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func primaryTapped() {
        onPrimaryTapped?()
    }
    
    @objc private func secondaryTapped() {
        onSecondaryTapped?()
    }
}


