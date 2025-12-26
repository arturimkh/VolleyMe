//
//  EventDetailsHeaderView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventDetailsHeaderView: UIView {
    
    // MARK: - UI Elements
    
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
        addSubview(titleLabel)
        addSubview(badgeView)
        badgeView.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            badgeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            badgeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            badgeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: 4),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 12),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -12),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: -4)
        ])
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
}

