//
//  EventDetailsViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

final class EventDetailsViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let scrollBottomInset: CGFloat = 80
        static let sectionSpacing: CGFloat = 16
    }
    
    // MARK: - Properties
    
    private let presenter: IEventDetailsPresenter
    private var viewModel: EventDetailsViewModel?
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.sectionSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var headerView: EventHeaderView = {
        let view = EventHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onBackTapped = { [weak self] in
            self?.presenter.didTapClose()
        }
        view.onMoreTapped = { [weak self] in
            self?.presenter.didTapMoreOptions()
        }
        return view
    }()
    
    private lazy var infoSectionView: EventInfoSectionView = {
        let view = EventInfoSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onCopyAddressTapped = { [weak self] in
            self?.presenter.didTapCopyAddress()
        }
        return view
    }()
    
    private lazy var descriptionView: EventDescriptionView = {
        let view = EventDescriptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToggleTapped = { [weak self] in
            self?.presenter.didToggleDescription()
        }
        return view
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
    
    private lazy var actionButtonView: EventActionButtonView = {
        let view = EventActionButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onPrimaryTapped = { [weak self] in
            self?.presenter.didTapPrimaryAction()
        }
        view.onSecondaryTapped = { [weak self] in
            self?.presenter.didTapSecondaryAction()
        }
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        setupContentStack()
        setupActionButton()
        setupLoadingIndicator()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.scrollBottomInset),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupContentStack() {
        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(infoSectionView)
        contentStackView.addArrangedSubview(descriptionView)
        contentStackView.addArrangedSubview(participantsSectionView)
        contentStackView.addArrangedSubview(hostsSectionView)
    }
    
    private func setupActionButton() {
        view.addSubview(actionButtonView)
        
        NSLayoutConstraint.activate([
            actionButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - IEventDetailsView

extension EventDetailsViewController: IEventDetailsView {
    
    func configure(with viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        
        headerView.configure(title: viewModel.title, roleBadge: viewModel.roleBadge)
        infoSectionView.configure(with: viewModel.infoItems)
        descriptionView.configure(with: viewModel.description)
        participantsSectionView.configure(with: viewModel.participantsSection)
        hostsSectionView.configure(with: viewModel.hostsSection)
        actionButtonView.configure(primary: viewModel.actionButton, secondary: viewModel.secondaryActionButton)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        scrollView.isHidden = true
        actionButtonView.isHidden = true
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
        actionButtonView.isHidden = false
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
