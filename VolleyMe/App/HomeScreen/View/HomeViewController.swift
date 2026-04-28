//
//  HomeViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter: IHomePresenter
    private var viewModel: HomeViewModel?
    private var sections: [EventSectionViewModel] = []
    private var showCreateButton = false
    
    // MARK: - UI Elements
    
    private lazy var headerView: HomeHeaderView = {
        let view = HomeHeaderView()
        view.onLogoutTapped = { [weak self] in
            self?.presenter.didTapLogout()
        }
        return view
    }()
    
    private lazy var tabSelectorView: TabSelectorView = {
        let view = TabSelectorView()
        view.onTabSelected = { [weak self] tab in
            self?.presenter.didSelectTab(tab)
        }
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(EventCardCell.self, forCellReuseIdentifier: EventCardCell.reuseIdentifier)
        table.register(CreateEventButtonCell.self, forCellReuseIdentifier: CreateEventButtonCell.reuseIdentifier)
        table.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 0
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        view.onPrimaryTapped = { [weak self] in
            self?.presenter.didTapCreateEvent()
        }
        view.onSecondaryTapped = { [weak self] in
            self?.presenter.didTapFindEvents()
        }
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(presenter: IHomePresenter) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(tabSelectorView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)
        
        tableView.refreshControl = refreshControl
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tabSelectorView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(tabSelectorView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(tabSelectorView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tableView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func pullToRefresh() {
        presenter.didPullToRefresh()
    }
    
    // MARK: - Private
    
    private func showLoadingState() {
        refreshControl.endRefreshing()
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
    }
    
    private func showEmptyState(viewModel: EmptyStateViewModel) {
        refreshControl.endRefreshing()
        loadingIndicator.stopAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = false
        emptyStateView.configure(with: viewModel)
    }
    
    private func showEventsState(viewModel: EventListViewModel) {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.isHidden = false
        emptyStateView.isHidden = true
        
        self.showCreateButton = viewModel.showCreateButton
        self.sections = viewModel.sections
        tableView.reloadData()
    }
}

// MARK: - IHomeView

extension HomeViewController: IHomeView {
    
    func configure(with viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        headerView.configure(with: viewModel.header)
        tabSelectorView.configure(with: viewModel.tabs)
        
        switch viewModel.content {
        case .loading:
            showLoadingState()
        case .empty(let emptyVM):
            showEmptyState(viewModel: emptyVM)
        case .events(let eventsVM):
            showEventsState(viewModel: eventsVM)
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLogoutAlert() {
        let alert = LogoutAlertViewController()
        alert.onConfirmLogout = { [weak self] in
            self?.presenter.didConfirmLogout()
        }
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let extra = showCreateButton ? 1 : 0
        return sections.count + extra
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showCreateButton && section == 0 {
            return 1
        }
        let sectionIndex = showCreateButton ? section - 1 : section
        return sections[sectionIndex].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showCreateButton && indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CreateEventButtonCell.reuseIdentifier,
                for: indexPath
            ) as? CreateEventButtonCell else {
                return UITableViewCell()
            }
            cell.onCreateTapped = { [weak self] in
                self?.presenter.didTapCreateEvent()
            }
            return cell
        }
        
        let sectionIndex = showCreateButton ? indexPath.section - 1 : indexPath.section
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EventCardCell.reuseIdentifier,
            for: indexPath
        ) as? EventCardCell else {
            return UITableViewCell()
        }
        
        let item = sections[sectionIndex].items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showCreateButton && section == 0 {
            return nil
        }
        
        let sectionIndex = showCreateButton ? section - 1 : section
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.reuseIdentifier
        ) as? SectionHeaderView else {
            return nil
        }
        
        let sectionVM = sections[sectionIndex]
        header.configure(title: sectionVM.title, count: sectionVM.count)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showCreateButton && section == 0 {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if showCreateButton && indexPath.section == 0 { return indexPath }
        let sectionIndex = showCreateButton ? indexPath.section - 1 : indexPath.section
        let item = sections[sectionIndex].items[indexPath.row]
        return item.isSelectable ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showCreateButton && indexPath.section == 0 { return }
        
        let sectionIndex = showCreateButton ? indexPath.section - 1 : indexPath.section
        let item = sections[sectionIndex].items[indexPath.row]
        guard item.isSelectable else { return }
        presenter.didTapEvent(id: item.id)
    }
}
