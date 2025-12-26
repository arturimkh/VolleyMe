//
//  EventDetailsViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter: IEventDetailsPresenter
    private var viewModel: EventDetailsViewModel?
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var headerView: EventDetailsHeaderView = {
        let view = EventDetailsHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var descriptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var toggleDescriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleDescriptionTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var participantsSectionView: ParticipantsSectionView = {
        let view = ParticipantsSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var hostsSectionView: ParticipantsSectionView = {
        let view = ParticipantsSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomButtonsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(presenter: IEventDetailsPresenter) {
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
        
        setupScrollView()
        setupHeader()
        setupInfoSection()
        setupDescriptionSection()
        setupParticipantsSection()
        setupBottomButtons()
        setupLoadingIndicator()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(closeButton)
        headerContainer.addSubview(moreButton)
        headerContainer.addSubview(headerView)
        
        contentStackView.addArrangedSubview(headerContainer)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            moreButton.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            headerView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            headerView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupInfoSection() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(infoContainerView)
        infoContainerView.addSubview(infoStackView)
        
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            infoContainerView.topAnchor.constraint(equalTo: container.topAnchor),
            infoContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            infoContainerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            infoContainerView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            infoStackView.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 8),
            infoStackView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            infoStackView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            infoStackView.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupDescriptionSection() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(descriptionContainerView)
        descriptionContainerView.addSubview(descriptionLabel)
        descriptionContainerView.addSubview(toggleDescriptionButton)
        
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            descriptionContainerView.topAnchor.constraint(equalTo: container.topAnchor),
            descriptionContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descriptionContainerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            descriptionContainerView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
            
            toggleDescriptionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            toggleDescriptionButton.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            toggleDescriptionButton.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupParticipantsSection() {
        contentStackView.addArrangedSubview(participantsSectionView)
        contentStackView.addArrangedSubview(hostsSectionView)
    }
    
    private func setupBottomButtons() {
        view.addSubview(bottomButtonsView)
        bottomButtonsView.addSubview(primaryButton)
        bottomButtonsView.addSubview(secondaryButton)
        
        NSLayoutConstraint.activate([
            bottomButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonsView.heightAnchor.constraint(equalToConstant: 120),
            
            primaryButton.topAnchor.constraint(equalTo: bottomButtonsView.topAnchor, constant: 8),
            primaryButton.leadingAnchor.constraint(equalTo: bottomButtonsView.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: bottomButtonsView.trailingAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: 50),
            
            secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 8),
            secondaryButton.leadingAnchor.constraint(equalTo: bottomButtonsView.leadingAnchor, constant: 16),
            secondaryButton.trailingAnchor.constraint(equalTo: bottomButtonsView.trailingAnchor, constant: -16),
            secondaryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        presenter.didTapClose()
    }
    
    @objc private func moreTapped() {
        presenter.didTapMoreOptions()
    }
    
    @objc private func toggleDescriptionTapped() {
        presenter.didToggleDescription()
    }
    
    @objc private func primaryButtonTapped() {
        presenter.didTapPrimaryAction()
    }
    
    @objc private func secondaryButtonTapped() {
        presenter.didTapSecondaryAction()
    }
    
    // MARK: - Private Methods
    
    private func configureInfoItems(_ items: [EventInfoItemViewModel]) {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            let cell = EventInfoCell(style: .default, reuseIdentifier: nil)
            cell.configure(with: item)
            cell.onCopyTapped = { [weak self] in
                self?.presenter.didTapCopyAddress()
            }
            
            infoStackView.addArrangedSubview(cell)
            
            // Добавляем разделитель между элементами
            if index < items.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .systemGray5
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                infoStackView.addArrangedSubview(separator)
            }
        }
    }
    
    private func configurePrimaryButton(with viewModel: ActionButtonViewModel) {
        primaryButton.setTitle(viewModel.title, for: .normal)
        primaryButton.isEnabled = viewModel.isEnabled
        
        switch viewModel.style {
        case .primary:
            primaryButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            primaryButton.setTitleColor(.white, for: .normal)
        case .secondary:
            primaryButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
            primaryButton.setTitleColor(.white, for: .normal)
        case .destructive:
            primaryButton.backgroundColor = .clear
            primaryButton.setTitleColor(.systemRed, for: .normal)
            primaryButton.layer.borderWidth = 1
            primaryButton.layer.borderColor = UIColor.systemRed.cgColor
        case .disabled:
            primaryButton.backgroundColor = .systemGray5
            primaryButton.setTitleColor(.systemGray, for: .normal)
        }
    }
    
    private func configureSecondaryButton(with viewModel: ActionButtonViewModel?) {
        guard let viewModel = viewModel else {
            secondaryButton.isHidden = true
            return
        }
        
        secondaryButton.isHidden = false
        secondaryButton.setTitle(viewModel.title, for: .normal)
        
        if let icon = viewModel.icon {
            secondaryButton.setImage(icon, for: .normal)
            secondaryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        
        secondaryButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        secondaryButton.setTitleColor(.white, for: .normal)
        secondaryButton.tintColor = .white
    }
}

// MARK: - IEventDetailsView

extension EventDetailsViewController: IEventDetailsView {
    
    func configure(with viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        
        headerView.configure(title: viewModel.title, roleBadge: viewModel.roleBadge)
        configureInfoItems(viewModel.infoItems)
        
        // Description
        if viewModel.description.isExpanded {
            descriptionLabel.text = viewModel.description.fullText
            toggleDescriptionButton.setTitle("Скрыть комментарий", for: .normal)
        } else {
            descriptionLabel.text = viewModel.description.previewText
            toggleDescriptionButton.setTitle("Показать комментарий", for: .normal)
        }
        toggleDescriptionButton.isHidden = !viewModel.description.showToggleButton
        
        // Participants
        participantsSectionView.configure(with: viewModel.participantsSection)
        hostsSectionView.configure(with: viewModel.hostsSection)
        
        // Buttons
        configurePrimaryButton(with: viewModel.actionButton)
        configureSecondaryButton(with: viewModel.secondaryActionButton)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        scrollView.isHidden = true
        bottomButtonsView.isHidden = true
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
        bottomButtonsView.isHidden = false
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showAlert(_ viewModel: AlertViewModel, onCheckboxChanged: @escaping (Bool) -> Void, onPrimaryAction: @escaping () -> Void) {
        let alertVC = CustomAlertViewController(viewModel: viewModel)
        alertVC.onCheckboxChanged = onCheckboxChanged
        alertVC.onPrimaryAction = onPrimaryAction
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
    func dismissAlert() {
        dismiss(animated: true)
    }
}

