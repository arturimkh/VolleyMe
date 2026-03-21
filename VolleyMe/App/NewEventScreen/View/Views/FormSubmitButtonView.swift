//
//  FormSubmitButtonView.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit
import SnapKit

final class FormSubmitButtonView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 26
    }
    
    // MARK: - UI Elements
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // MARK: - Properties
    
    var onSubmitTapped: (() -> Void)?
    
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
        backgroundColor = .systemBackground
        
        addSubview(separatorView)
        addSubview(button)
        
        separatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(Constants.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.height.equalTo(Constants.buttonHeight)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Constants.verticalPadding)
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: FormSubmitButtonViewModel) {
        button.setTitle(viewModel.title, for: .normal)
        button.isEnabled = viewModel.isEnabled
        button.backgroundColor = viewModel.isEnabled ? .systemBlue : .systemGray4
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped() {
        onSubmitTapped?()
    }
}
