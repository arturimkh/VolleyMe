//
//  LogoutAlertViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class LogoutAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    var onConfirmLogout: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выйти?"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Восстановление учетных данных в разработке.\n\nЕсли вы не сохранили никнейм и пароль ранее, вы можете потерять доступ к аккаунту."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)
        return button
    }()
    
    private lazy var stayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Не выходить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(dismiss_), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(dismiss_), for: .touchUpInside)
        return button
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(divider)
        containerView.addSubview(logoutButton)
        containerView.addSubview(stayButton)
        containerView.addSubview(cancelButton)
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(0.5)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(28)
        }
        
        stayButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(28)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(stayButton.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().inset(24)
        }
        
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dismiss_))
        dimView.addGestureRecognizer(dimTap)
    }
    
    // MARK: - Actions
    
    @objc private func confirmLogout() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirmLogout?()
        }
    }
    
    @objc private func dismiss_() {
        dismiss(animated: true)
    }
}
