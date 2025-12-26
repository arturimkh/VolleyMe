//
//  ParticipantsSectionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class ParticipantsSectionView: UIView {
    
    // MARK: - UI Elements
    
    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let participantsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        addSubview(headerStackView)
        addSubview(participantsStackView)
        
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(countLabel)
        headerStackView.addArrangedSubview(UIView()) // Spacer
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            participantsStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            participantsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            participantsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            participantsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: ParticipantsSectionViewModel) {
        titleLabel.text = viewModel.title
        countLabel.text = viewModel.countText
        
        // Очищаем старые ячейки
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новые
        for participant in viewModel.participants {
            let cell = ParticipantCell(style: .default, reuseIdentifier: nil)
            cell.configure(with: participant)
            participantsStackView.addArrangedSubview(cell)
            
            // Устанавливаем высоту ячейки
            cell.heightAnchor.constraint(equalToConstant: 56).isActive = true
        }
    }
}

