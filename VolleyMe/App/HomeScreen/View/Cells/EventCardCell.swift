//
//  EventCardCell.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class EventCardCell: UITableViewCell {
    
    static let reuseIdentifier = "EventCardCell"
    
    // MARK: - Constants
    
    private enum Constants {
        static let cardInsetH: CGFloat = 16
        static let cardInsetV: CGFloat = 6
        static let cardPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let badgeCornerRadius: CGFloat = 10
        static let participantIconSize: CGFloat = 16
    }
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        return stack
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let bottomRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let participantIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        imageView.image = UIImage(systemName: "person.2.fill", withConfiguration: config)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let participantCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let badgeContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
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
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        badgeContainer.isHidden = true
        cardView.alpha = 1
        isUserInteractionEnabled = true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(topRowStack)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(bottomRowStack)
        
        topRowStack.addArrangedSubview(dateTimeLabel)
        topRowStack.addArrangedSubview(priceLabel)
        
        bottomRowStack.addArrangedSubview(participantIcon)
        bottomRowStack.addArrangedSubview(participantCountLabel)
        bottomRowStack.addArrangedSubview(badgeContainer)
        bottomRowStack.addArrangedSubview(UIView()) // spacer
        
        badgeContainer.addSubview(badgeLabel)
        
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.cardInsetV)
            make.leading.equalToSuperview().offset(Constants.cardInsetH)
            make.trailing.equalToSuperview().offset(-Constants.cardInsetH)
            make.bottom.equalToSuperview().offset(-Constants.cardInsetV)
        }
        
        topRowStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.cardPadding)
            make.leading.equalToSuperview().offset(Constants.cardPadding)
            make.trailing.equalToSuperview().offset(-Constants.cardPadding)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topRowStack.snp.bottom).offset(4)
            make.leading.trailing.equalTo(topRowStack)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(topRowStack)
        }
        
        bottomRowStack.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(Constants.cardPadding)
            make.trailing.equalToSuperview().offset(-Constants.cardPadding)
            make.bottom.equalToSuperview().offset(-Constants.cardPadding)
        }
        
        participantIcon.snp.makeConstraints { make in
            make.size.equalTo(Constants.participantIconSize)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
        
        badgeContainer.layer.cornerRadius = Constants.badgeCornerRadius
        badgeContainer.clipsToBounds = true
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: EventCardViewModel) {
        dateTimeLabel.text = viewModel.dateTimeText
        priceLabel.text = viewModel.priceText
        priceLabel.textColor = viewModel.priceColor
        subtitleLabel.text = viewModel.subtitle
        addressLabel.text = viewModel.address
        participantCountLabel.text = viewModel.participantCountText
        
        if let badge = viewModel.roleBadge {
            badgeContainer.isHidden = false
            badgeContainer.backgroundColor = badge.backgroundColor
            badgeLabel.text = badge.text
            badgeLabel.textColor = badge.textColor
        } else {
            badgeContainer.isHidden = true
        }
        
        cardView.alpha = viewModel.isSelectable ? 1 : 0.45
        isUserInteractionEnabled = viewModel.isSelectable
    }
}
