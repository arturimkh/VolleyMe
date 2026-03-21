//
//  EmptyStateView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let illustrationSize: CGFloat = 150
        static let buttonHeight: CGFloat = 52
        static let buttonWidth: CGFloat = 240
        static let horizontalPadding: CGFloat = 40
    }
    
    // MARK: - UI Elements
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    private let illustrationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        label.text = "\u{1F3D0}"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
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
        addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(illustrationLabel)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        containerStackView.addArrangedSubview(primaryButton)
        containerStackView.addArrangedSubview(secondaryButton)
        
        containerStackView.setCustomSpacing(8, after: titleLabel)
        containerStackView.setCustomSpacing(24, after: subtitleLabel)
        containerStackView.setCustomSpacing(12, after: primaryButton)
        
        containerStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(Constants.horizontalPadding)
            make.trailing.lessThanOrEqualToSuperview().offset(-Constants.horizontalPadding)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(Constants.buttonHeight)
            make.width.equalTo(Constants.buttonWidth)
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: EmptyStateViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        if let icon = viewModel.primaryButtonIcon {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = icon.withTintColor(.white)
            imageAttachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
            
            let attributedString = NSMutableAttributedString(attachment: imageAttachment)
            attributedString.append(NSAttributedString(string: "  \(viewModel.primaryButtonTitle)"))
            primaryButton.setAttributedTitle(attributedString, for: .normal)
            primaryButton.setTitleColor(.white, for: .normal)
        } else {
            primaryButton.setTitle(viewModel.primaryButtonTitle, for: .normal)
        }
        
        if let secondaryTitle = viewModel.secondaryButtonTitle {
            secondaryButton.isHidden = false
            if let icon = viewModel.secondaryButtonIcon {
                let config = UIImage.SymbolConfiguration(pointSize: 13)
                let image = icon.withConfiguration(config)
                secondaryButton.setImage(image, for: .normal)
                secondaryButton.setTitle("  \(secondaryTitle)", for: .normal)
            } else {
                secondaryButton.setTitle(secondaryTitle, for: .normal)
            }
        } else {
            secondaryButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func primaryTapped() {
        onPrimaryTapped?()
    }
    
    @objc private func secondaryTapped() {
        onSecondaryTapped?()
    }
}
