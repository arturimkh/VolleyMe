//
//  TabSelectorView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class TabSelectorView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let height: CGFloat = 44
        static let indicatorHeight: CGFloat = 2
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - UI Elements
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = Constants.indicatorHeight / 2
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // MARK: - Properties
    
    var onTabSelected: ((HomeTab) -> Void)?
    private var tabButtons: [UIButton] = []
    private var selectedIndex: Int = 0
    
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
        addSubview(stackView)
        addSubview(separatorView)
        addSubview(indicatorView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.height.equalTo(Constants.height)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with tabs: [HomeTabViewModel]) {
        tabButtons.forEach { $0.removeFromSuperview() }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        for (index, tab) in tabs.enumerated() {
            let button = createTabButton(tab: tab, index: index)
            stackView.addArrangedSubview(button)
            tabButtons.append(button)
            
            if tab.isSelected {
                selectedIndex = index
            }
        }
        
        layoutIfNeeded()
        updateIndicator(animated: false)
    }
    
    // MARK: - Private
    
    private func createTabButton(tab: HomeTabViewModel, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let icon = tab.icon?.withConfiguration(iconConfig)
        
        var config = UIButton.Configuration.plain()
        config.image = icon
        config.title = tab.title
        config.imagePadding = 6
        config.baseForegroundColor = tab.isSelected ? .systemBlue : .systemGray
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attrs = incoming
            attrs.font = .systemFont(ofSize: 14, weight: tab.isSelected ? .semibold : .regular)
            return attrs
        }
        
        button.configuration = config
        button.tag = index
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateIndicator(animated: Bool) {
        guard selectedIndex < tabButtons.count else { return }
        let selectedButton = tabButtons[selectedIndex]
        
        indicatorView.snp.remakeConstraints { make in
            make.bottom.equalTo(separatorView.snp.top)
            make.height.equalTo(Constants.indicatorHeight)
            make.leading.trailing.equalTo(selectedButton)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func tabTapped(_ sender: UIButton) {
        guard let tab = HomeTab(rawValue: sender.tag) else { return }
        onTabSelected?(tab)
    }
}
