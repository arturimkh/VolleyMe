//
//  EventInfoSectionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventInfoSectionView: UIView {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
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
            
            // Добавляем разделитель после каждого элемента, кроме последнего
            if index < items.count - 1 {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }
    }
    
    // MARK: - Private
    
    private func createSeparator() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(line)
        
        // Высота 1 пиксель (1 / scale экрана)
        let pixelHeight: CGFloat = 1
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: pixelHeight),
            
            // Линия с отступом слева (как текст - после иконки)
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 48),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -48),
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Text
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            textLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            
            // Copy button
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            copyButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Min height
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
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


