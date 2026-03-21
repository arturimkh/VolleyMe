//
//  FormTextFieldView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit
import SnapKit

final class FormTextFieldView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 14
        static let iconSize: CGFloat = 20
        static let clearButtonSize: CGFloat = 20
        static let minHeight: CGFloat = 52
        static let multilineMinHeight: CGFloat = 100
    }
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let floatingLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .label
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    
    var onTextChanged: ((String) -> Void)?
    var onClearTapped: (() -> Void)?
    
    private var isMultiline = false
    private var hasIcon = false
    private var showsClearButton = false
    
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
        addSubview(containerView)
        addSubview(floatingLabelContainer)
        addSubview(hintLabel)
        addSubview(errorLabel)
        
        floatingLabelContainer.addSubview(floatingLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(textField)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(clearButton)
        
        textView.isHidden = true
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(Constants.minHeight)
        }
        
        floatingLabelContainer.snp.makeConstraints { make in
            make.centerY.equalTo(containerView.snp.top)
            make.leading.equalTo(containerView).offset(12)
        }
        
        floatingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(Constants.horizontalPadding)
            make.centerY.equalTo(containerView)
            make.size.equalTo(Constants.iconSize)
        }
        
        clearButton.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-Constants.horizontalPadding)
            make.centerY.equalTo(containerView)
            make.size.equalTo(Constants.clearButtonSize)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(Constants.horizontalPadding)
            make.trailing.equalTo(containerView).offset(-Constants.horizontalPadding)
            make.centerY.equalTo(containerView)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(Constants.verticalPadding)
            make.bottom.equalTo(containerView).offset(-Constants.verticalPadding)
            make.leading.equalTo(containerView).offset(Constants.horizontalPadding)
            make.trailing.equalTo(containerView).offset(-Constants.horizontalPadding)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField)
            make.centerY.equalTo(containerView)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(containerView)
            make.bottom.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(containerView)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: FormTextFieldViewModel) {
        isMultiline = viewModel.isMultiline
        hasIcon = viewModel.icon != nil
        showsClearButton = viewModel.showClearButton
        
        // Setup for multiline or single line
        if viewModel.isMultiline {
            textField.isHidden = true
            textView.isHidden = false
            textView.text = viewModel.text
            
            containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.height.greaterThanOrEqualTo(Constants.multilineMinHeight)
            }
            
            textView.snp.remakeConstraints { make in
                make.top.equalTo(containerView).offset(Constants.verticalPadding)
                make.bottom.equalTo(containerView).offset(-Constants.verticalPadding)
                make.leading.equalTo(containerView).offset(Constants.horizontalPadding)
                make.trailing.equalTo(containerView).offset(-Constants.horizontalPadding)
            }
            
            placeholderLabel.snp.remakeConstraints { make in
                make.leading.equalTo(textView)
                make.top.equalTo(textView)
            }
        } else {
            textField.isHidden = false
            textView.isHidden = true
            textField.text = viewModel.text
            textField.keyboardType = viewModel.keyboardType
            
            containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(Constants.minHeight)
            }
            
            // Update textField constraints based on icon and clear button
            let leadingOffset: CGFloat = hasIcon ? Constants.horizontalPadding + Constants.iconSize + 12 : Constants.horizontalPadding
            let trailingOffset: CGFloat = (viewModel.showClearButton && !viewModel.text.isEmpty) ? -(Constants.horizontalPadding + Constants.clearButtonSize + 8) : -Constants.horizontalPadding
            
            textField.snp.remakeConstraints { make in
                make.leading.equalTo(containerView).offset(leadingOffset)
                make.trailing.equalTo(containerView).offset(trailingOffset)
                make.centerY.equalTo(containerView)
            }
            
            placeholderLabel.snp.remakeConstraints { make in
                make.leading.equalTo(textField)
                make.centerY.equalTo(containerView)
            }
        }
        
        // Icon
        if let icon = viewModel.icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        
        // Clear button
        clearButton.isHidden = viewModel.text.isEmpty || !viewModel.showClearButton
        
        // Placeholder
        placeholderLabel.text = viewModel.placeholder
        placeholderLabel.isHidden = !viewModel.text.isEmpty
        
        // Floating label
        if !viewModel.text.isEmpty {
            floatingLabel.text = viewModel.placeholder
            floatingLabelContainer.isHidden = false
        } else {
            floatingLabelContainer.isHidden = true
        }
        
        // Hint/Error
        let hasHintOrError = viewModel.hint != nil || viewModel.errorMessage != nil
        
        if let error = viewModel.errorMessage {
            errorLabel.text = error
            errorLabel.isHidden = false
            hintLabel.isHidden = true
            containerView.layer.borderColor = UIColor.systemRed.cgColor
            floatingLabel.textColor = .systemRed
        } else {
            errorLabel.isHidden = true
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            floatingLabel.textColor = .systemGray
            
            if let hint = viewModel.hint {
                hintLabel.text = hint
                hintLabel.isHidden = false
            } else {
                hintLabel.isHidden = true
            }
        }
        
        // Update bottom constraint
        if !hasHintOrError {
            hintLabel.snp.remakeConstraints { make in
                make.top.equalTo(containerView.snp.bottom)
                make.leading.trailing.equalTo(containerView)
                make.height.equalTo(0)
                make.bottom.equalToSuperview()
            }
            errorLabel.snp.remakeConstraints { make in
                make.top.equalTo(containerView.snp.bottom)
                make.leading.trailing.equalTo(containerView)
                make.height.equalTo(0)
                make.bottom.equalToSuperview()
            }
        } else {
            hintLabel.snp.remakeConstraints { make in
                make.top.equalTo(containerView.snp.bottom).offset(4)
                make.leading.trailing.equalTo(containerView)
                make.bottom.equalToSuperview()
            }
            errorLabel.snp.remakeConstraints { make in
                make.top.equalTo(containerView.snp.bottom).offset(4)
                make.leading.trailing.equalTo(containerView)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        floatingLabelContainer.isHidden = text.isEmpty
        clearButton.isHidden = text.isEmpty || !showsClearButton
        onTextChanged?(text)
    }
    
    @objc private func clearButtonTapped() {
        textField.text = ""
        placeholderLabel.isHidden = false
        floatingLabelContainer.isHidden = true
        clearButton.isHidden = true
        onClearTapped?()
    }
}

// MARK: - UITextFieldDelegate

extension FormTextFieldView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        containerView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}

// MARK: - UITextViewDelegate

extension FormTextFieldView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        floatingLabelContainer.isHidden = text.isEmpty
        onTextChanged?(text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        containerView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
