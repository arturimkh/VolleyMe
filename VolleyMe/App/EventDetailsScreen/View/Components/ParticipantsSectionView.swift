//
//  ParticipantsSectionView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

final class ParticipantsSectionView: UIView {
    
    // MARK: - UI Elements
    
    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
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
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        participantsStackView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: ParticipantsSectionViewModel) {
        titleLabel.text = viewModel.title
        countLabel.text = viewModel.countText
        
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for participant in viewModel.participants {
            let cell = ParticipantCell(style: .default, reuseIdentifier: nil)
            cell.configure(with: participant)
            participantsStackView.addArrangedSubview(cell)
            
            cell.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
}
