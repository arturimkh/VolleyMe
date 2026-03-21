//
//  SectionHeaderView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "SectionHeaderView"
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        let bg = UIView()
        bg.backgroundColor = .systemBackground
        backgroundView = bg
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "\(count)"
    }
}
