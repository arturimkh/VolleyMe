//
//  OnboardingViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 32
        static let buttonHeight: CGFloat = 52
        static let phoneAspectRatio: CGFloat = 1.85
        static let phoneWidth: CGFloat = 160
        static let dotSize: CGFloat = 8
        static let dotSpacing: CGFloat = 10
        static let animationDuration: TimeInterval = 0.4
    }
    
    // MARK: - Properties
    
    private let presenter: IOnboardingPresenter
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .systemBlue
        button.isHidden = true
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleNavLabel: UILabel = {
        let label = UILabel()
        label.text = "О приложении"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пропустить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()
    
    private let contentContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let phoneFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let phonePlaceholderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Скриншот"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemGray2
        label.textAlignment = .center
        return label
    }()
    
    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let pageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.dotSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = Constants.buttonHeight / 2
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(presenter: IOnboardingPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(backButton)
        view.addSubview(titleNavLabel)
        view.addSubview(skipButton)
        view.addSubview(contentContainerView)
        view.addSubview(dotsStackView)
        view.addSubview(actionButton)
        
        contentContainerView.addSubview(phoneFrameView)
        phoneFrameView.addSubview(phonePlaceholderView)
        phonePlaceholderView.addSubview(placeholderLabel)
        contentContainerView.addSubview(pageTitleLabel)
        contentContainerView.addSubview(pageSubtitleLabel)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.size.equalTo(32)
        }
        
        titleNavLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        skipButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton)
        }
        
        contentContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleNavLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(dotsStackView.snp.top).offset(-20)
        }
        
        phoneFrameView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.phoneWidth)
            make.height.equalTo(Constants.phoneWidth * Constants.phoneAspectRatio)
        }
        
        phonePlaceholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        pageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneFrameView.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
        }
        
        pageSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
        }
        
        dotsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(actionButton.snp.top).offset(-24)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(Constants.buttonHeight)
        }
    }
    
    // MARK: - Animations
    
    private func animateTransition(direction: Int) {
        let offset: CGFloat = 40 * CGFloat(direction)
        
        let snapshot = contentContainerView.snapshotView(afterScreenUpdates: false)
        if let snapshot = snapshot {
            contentContainerView.addSubview(snapshot)
            snapshot.frame = contentContainerView.bounds
        }
        
        pageTitleLabel.transform = CGAffineTransform(translationX: offset, y: 0)
        pageTitleLabel.alpha = 0
        pageSubtitleLabel.transform = CGAffineTransform(translationX: offset, y: 0)
        pageSubtitleLabel.alpha = 0
        phonePlaceholderView.alpha = 0
        
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseInOut) {
            snapshot?.transform = CGAffineTransform(translationX: -offset, y: 0)
            snapshot?.alpha = 0
            
            self.pageTitleLabel.transform = .identity
            self.pageTitleLabel.alpha = 1
            self.pageSubtitleLabel.transform = .identity
            self.pageSubtitleLabel.alpha = 1
            self.phonePlaceholderView.alpha = 1
        } completion: { _ in
            snapshot?.removeFromSuperview()
        }
    }
    
    private func updateDots(activeIndex: Int) {
        for (i, dot) in dotsStackView.arrangedSubviews.enumerated() {
            UIView.animate(withDuration: 0.25) {
                dot.backgroundColor = i == activeIndex ? .systemBlue : .systemGray4
                dot.transform = i == activeIndex
                    ? CGAffineTransform(scaleX: 1.3, y: 1.3)
                    : .identity
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func actionTapped() {
        presenter.didTapAction()
    }
    
    @objc private func backTapped() {
        presenter.didTapBack()
    }
    
    @objc private func skipTapped() {
        presenter.didTapSkip()
    }
}

// MARK: - IOnboardingView

extension OnboardingViewController: IOnboardingView {
    
    func setupDots(count: Int) {
        dotsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<count {
            let dot = UIView()
            dot.tag = i
            dot.layer.cornerRadius = Constants.dotSize / 2
            dot.snp.makeConstraints { make in
                make.size.equalTo(Constants.dotSize)
            }
            dotsStackView.addArrangedSubview(dot)
        }
    }
    
    func configure(with viewModel: OnboardingViewModel, animated: Bool, direction: Int) {
        pageTitleLabel.text = viewModel.title
        pageSubtitleLabel.text = viewModel.subtitle
        actionButton.setTitle(viewModel.buttonTitle, for: .normal)
        phonePlaceholderView.backgroundColor = viewModel.placeholderColor
        placeholderLabel.text = viewModel.placeholderText
        backButton.isHidden = !viewModel.showBackButton
        
        updateDots(activeIndex: viewModel.currentPage)
        
        if animated && direction != 0 {
            animateTransition(direction: direction)
        }
    }
}
