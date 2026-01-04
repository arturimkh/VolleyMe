//
//  EventDescriptionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventDescriptionView: UIView {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onToggleTapped: (() -> Void)?
    
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
        containerView.addSubview(textLabel)
        containerView.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            toggleButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            toggleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            toggleButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            toggleButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: DescriptionViewModel) {
        if viewModel.isExpanded {
            textLabel.text = viewModel.fullText
            toggleButton.setTitle("Скрыть комментарий", for: .normal)
        } else {
            textLabel.text = viewModel.previewText
            toggleButton.setTitle("Показать комментарий", for: .normal)
        }
        toggleButton.isHidden = !viewModel.showToggleButton
    }
    
    // MARK: - Actions
    
    @objc private func toggleTapped() {
        onToggleTapped?()
    }
}


