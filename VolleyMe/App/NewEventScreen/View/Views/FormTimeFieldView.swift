//
//  FormTimeFieldView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit
import SnapKit

final class FormTimeFieldView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 12
        static let iconSize: CGFloat = 20
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
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.minuteInterval = 5
        picker.contentHorizontalAlignment = .leading
        picker.tintColor = .label
        picker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        return picker
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
    
    var onTimeChanged: ((Date) -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timePicker.tintColor = .label
        applyPlainCompactStyle(to: timePicker)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        addSubview(floatingLabelContainer)
        addSubview(errorLabel)
        
        floatingLabelContainer.addSubview(floatingLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(timePicker)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.fieldHeight)
            make.bottom.equalToSuperview()
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
        
        timePicker.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.top.bottom.equalTo(containerView)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(containerView)
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: FormTimeFieldViewModel) {
        floatingLabel.text = viewModel.label
        timePicker.date = viewModel.time
        
        if let icon = viewModel.icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        
        if let error = viewModel.errorMessage {
            errorLabel.text = error
            errorLabel.isHidden = false
            containerView.layer.borderColor = UIColor.systemRed.cgColor
            floatingLabel.textColor = .systemRed
            
            containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Constants.fieldHeight)
            }
            
            errorLabel.snp.remakeConstraints { make in
                make.top.equalTo(containerView.snp.bottom).offset(4)
                make.leading.trailing.equalTo(containerView)
                make.bottom.equalToSuperview()
            }
        } else {
            errorLabel.isHidden = true
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            floatingLabel.textColor = .systemGray
            
            containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Constants.fieldHeight)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func timeChanged() {
        onTimeChanged?(timePicker.date)
    }
    
    // MARK: - Helpers
    
    private func applyPlainCompactStyle(to view: UIView) {
        view.backgroundColor = .clear
        if let label = view as? UILabel {
            label.textColor = .label
            label.backgroundColor = .clear
        }
        if #available(iOS 15.0, *) {
            if let button = view as? UIButton {
                button.tintColor = .label
                if var config = button.configuration {
                    config.background.backgroundColor = .clear
                    config.baseForegroundColor = .label
                    button.configuration = config
                }
            }
        }
        view.subviews.forEach { applyPlainCompactStyle(to: $0) }
    }
}
