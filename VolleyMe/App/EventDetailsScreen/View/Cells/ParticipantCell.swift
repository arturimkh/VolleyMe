//
//  ParticipantCell.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class ParticipantCell: UITableViewCell {
    
    static let reuseIdentifier = "ParticipantCell"
    
    // MARK: - UI Elements
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentUserLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(currentUserLabel)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            avatarView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            avatarView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            currentUserLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            currentUserLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            currentUserLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: ParticipantCellViewModel) {
        avatarLabel.text = viewModel.avatarText
        nameLabel.text = viewModel.name
        currentUserLabel.text = viewModel.currentUserSuffix
        currentUserLabel.isHidden = viewModel.currentUserSuffix == nil
        
        // Делаем текущего пользователя немного серым
        if viewModel.isCurrentUser {
            nameLabel.textColor = .systemGray
        } else {
            nameLabel.textColor = .label
        }
    }
}


