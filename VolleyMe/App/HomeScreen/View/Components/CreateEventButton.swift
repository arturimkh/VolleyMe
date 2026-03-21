//
//  CreateEventButton.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class CreateEventButton: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - UI Elements
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let icon = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.setTitle("Создать встречу", for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    var onTapped: (() -> Void)?
    
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
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.height.equalTo(Constants.height)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Actions
    
    @objc private func tapped() {
        onTapped?()
    }
}
