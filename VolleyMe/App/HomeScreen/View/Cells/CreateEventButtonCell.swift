//
//  CreateEventButtonCell.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 03.04.2026.
//

import UIKit
import SnapKit

final class CreateEventButtonCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "CreateEventButtonCell"
    
    // MARK: - UI Elements
    
    private let createButton = CreateEventButton()
    
    // MARK: - Properties
    
    var onCreateTapped: (() -> Void)? {
        get { createButton.onTapped }
        set { createButton.onTapped = newValue }
    }
    
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
        contentView.backgroundColor = .clear
        
        contentView.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
