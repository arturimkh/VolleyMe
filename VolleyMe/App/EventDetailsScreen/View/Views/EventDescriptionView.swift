//
//  EventDescriptionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

final class EventDescriptionView: UIView {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentHorizontalAlignment = .left
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
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
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
