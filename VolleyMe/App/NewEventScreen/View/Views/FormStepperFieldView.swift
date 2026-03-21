//
//  FormStepperFieldView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit
import SnapKit

final class FormStepperFieldView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let buttonSize: CGFloat = 32
        static let fieldHeight: CGFloat = 52
    }
    
    // MARK: - UI Elements
    
    private let floatingLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private lazy var decrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        return button
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
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
    
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?
    
    private var minValue: Int = 0
    private var maxValue: Int = 100
    private var currentValue: Int = 0
    
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
        containerView.addSubview(decrementButton)
        containerView.addSubview(valueLabel)
        containerView.addSubview(incrementButton)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(Constants.fieldHeight)
        }
        
        floatingLabelContainer.snp.makeConstraints { make in
            make.centerY.equalTo(containerView.snp.top)
            make.leading.equalTo(containerView).offset(12)
        }
        
        floatingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        }
        
        decrementButton.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(Constants.horizontalPadding)
            make.centerY.equalTo(containerView)
            make.size.equalTo(Constants.buttonSize)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.center.equalTo(containerView)
        }
        
        incrementButton.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-Constants.horizontalPadding)
            make.centerY.equalTo(containerView)
            make.size.equalTo(Constants.buttonSize)
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
    
    func configure(with viewModel: FormStepperFieldViewModel) {
        floatingLabel.text = viewModel.label
        valueLabel.text = "\(viewModel.value)"
        
        currentValue = viewModel.value
        minValue = viewModel.minValue
        maxValue = viewModel.maxValue
        
        // Обновляем состояние кнопок
        decrementButton.isEnabled = currentValue > minValue
        decrementButton.tintColor = currentValue > minValue ? .systemBlue : .systemGray3
        
        incrementButton.isEnabled = currentValue < maxValue
        incrementButton.tintColor = currentValue < maxValue ? .systemBlue : .systemGray3
        
        // Hint/Error
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
    }
    
    // MARK: - Actions
    
    @objc private func decrementTapped() {
        onDecrement?()
    }
    
    @objc private func incrementTapped() {
        onIncrement?()
    }
}
