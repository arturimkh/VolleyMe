//
//  EventHeaderView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

final class EventHeaderView: UIView {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        badgeView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-4)
        }
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
