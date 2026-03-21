//
//  EventActionButtonView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

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
        return view
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        return button
    }()
    
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.isHidden = true
        return button
    }()
    
    var onPrimaryTapped: (() -> Void)?
    var onSecondaryTapped: (() -> Void)?
    
    private var hasSecondaryButton = false
    
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
        
        topSeparator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(topSeparator.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
        
        updateBottomConstraint()
        
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
    }
    
    private func updateBottomConstraint() {
        if hasSecondaryButton {
            primaryButton.snp.removeConstraints()
            primaryButton.snp.makeConstraints { make in
                make.top.equalTo(topSeparator.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(Constants.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
                make.height.equalTo(Constants.buttonHeight)
            }
            secondaryButton.snp.remakeConstraints { make in
                make.top.equalTo(primaryButton.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(Constants.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
                make.height.equalTo(Constants.buttonHeight)
                make.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
            }
        } else {
            primaryButton.snp.remakeConstraints { make in
                make.top.equalTo(topSeparator.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(Constants.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
                make.height.equalTo(Constants.buttonHeight)
                make.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
            }
        }
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
            hasSecondaryButton = false
            updateBottomConstraint()
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
        
        hasSecondaryButton = true
        updateBottomConstraint()
    }
    
    // MARK: - Actions
    
    @objc private func primaryTapped() {
        onPrimaryTapped?()
    }
    
    @objc private func secondaryTapped() {
        onSecondaryTapped?()
    }
}
