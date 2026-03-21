//
//  EventDetailsViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit
import SnapKit

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
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.sectionSpacing
        return stack
    }()
    
    private lazy var headerView: EventHeaderView = {
        let view = EventHeaderView()
        return view
    }()
    
    private lazy var infoSectionView: EventInfoSectionView = {
        let view = EventInfoSectionView()
        view.onCopyAddressTapped = { [weak self] in
            self?.presenter.didTapCopyAddress()
        }
        return view
    }()
    
    private lazy var descriptionView: EventDescriptionView = {
        let view = EventDescriptionView()
        view.onToggleTapped = { [weak self] in
            self?.presenter.didToggleDescription()
        }
        return view
    }()
    
    private lazy var participantsSectionView: ParticipantsSectionView = {
        let view = ParticipantsSectionView()
        return view
    }()
    
    private lazy var hostsSectionView: ParticipantsSectionView = {
        let view = ParticipantsSectionView()
        return view
    }()
    
    private lazy var actionButtonView: EventActionButtonView = {
        let view = EventActionButtonView()
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
        setupNavigationBar()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Показываем navigationBar при появлении экрана
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentStack()
        setupActionButton()
        setupLoadingIndicator()
    }
    
    private func setupNavigationBar() {
        // Заголовок будет в headerView, здесь только кнопки
        title = ""
        
        // Кнопка "..." справа
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(moreTapped)
        )
        moreButton.tintColor = .label
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.scrollBottomInset)
            make.width.equalTo(scrollView)
        }
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
        
        actionButtonView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    
    @objc private func moreTapped() {
        presenter.didTapMoreOptions()
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
