//
//  EventInfoSectionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

final class EventInfoSectionView: UIView {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    var onCopyAddressTapped: (() -> Void)?
    
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
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    // MARK: - Configure
    
    func configure(with items: [EventInfoItemViewModel]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            let itemView = EventInfoItemView()
            itemView.configure(with: item)
            itemView.onCopyTapped = { [weak self] in
                self?.onCopyAddressTapped?()
            }
            stackView.addArrangedSubview(itemView)
            
            if index < items.count - 1 {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }
    }
    
    // MARK: - Private
    
    private func createSeparator() -> UIView {
        let container = UIView()
        
        let line = UIView()
        line.backgroundColor = .systemGray5
        
        container.addSubview(line)
        
        container.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        line.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(48)
            make.trailing.equalToSuperview().offset(-48)
            make.top.bottom.equalToSuperview()
        }
        
        return container
    }
}

// MARK: - EventInfoItemView

final class EventInfoItemView: UIView {
    
    // MARK: - UI Elements
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .systemGray
        button.isHidden = true
        return button
    }()
    
    var onCopyTapped: (() -> Void)?
    
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
        addSubview(iconImageView)
        addSubview(textLabel)
        addSubview(copyButton)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(20)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalTo(copyButton.snp.leading).offset(-8)
        }
        
        copyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: EventInfoItemViewModel) {
        iconImageView.image = viewModel.icon
        textLabel.text = viewModel.text
        copyButton.isHidden = !viewModel.showCopyButton
    }
    
    // MARK: - Actions
    
    @objc private func copyTapped() {
        onCopyTapped?()
    }
}
