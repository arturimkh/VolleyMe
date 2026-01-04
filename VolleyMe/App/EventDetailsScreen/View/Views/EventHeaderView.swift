//
//  EventHeaderView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventHeaderView: UIView {
    
    // MARK: - UI Elements
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onBackTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?
    
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
        addSubview(backButton)
        addSubview(moreButton)
        addSubview(titleLabel)
        addSubview(badgeView)
        badgeView.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            // Back button
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            // More button
            moreButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Badge
            badgeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            badgeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            badgeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            badgeLabel.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: 4),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 12),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -12),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: -4)
        ])
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(title: String, roleBadge: RoleBadgeViewModel?) {
        titleLabel.text = title
        
        if let badge = roleBadge {
            badgeView.isHidden = false
            badgeView.backgroundColor = badge.backgroundColor
            badgeLabel.text = badge.text
            badgeLabel.textColor = badge.textColor
        } else {
            badgeView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onBackTapped?()
    }
    
    @objc private func moreTapped() {
        onMoreTapped?()
    }
}


