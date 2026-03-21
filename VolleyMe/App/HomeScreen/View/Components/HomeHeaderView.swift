//
//  HomeHeaderView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class HomeHeaderView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let avatarSize: CGFloat = 36
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
    }
    
    // MARK: - UI Elements
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = Constants.avatarSize / 2
        view.clipsToBounds = true
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        
        let config = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.semanticContentAttribute = .forceLeftToRight
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    var onLogoutTapped: (() -> Void)?
    
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
        addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        addSubview(usernameLabel)
        addSubview(logoutButton)
        
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Constants.avatarSize)
        }
        
        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.centerY.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(Constants.avatarSize + Constants.verticalPadding * 2)
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: HomeHeaderViewModel) {
        avatarLabel.text = viewModel.avatarText
        usernameLabel.text = viewModel.username
        logoutButton.setTitle(" \(viewModel.logoutTitle)", for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
}
