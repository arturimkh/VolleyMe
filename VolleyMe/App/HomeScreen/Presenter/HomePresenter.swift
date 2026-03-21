//
//  HomePresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import Foundation

// MARK: - View Protocol

protocol IHomeView: AnyObject {
    func configure(with viewModel: HomeViewModel)
    func showLogoutAlert()
}

// MARK: - Output Protocol

protocol IHomeOutput: AnyObject {
    func homeDidSelectEvent(eventId: String)
    func homeDidTapCreateEvent()
    func homeDidTapFindEvents()
    func homeDidTapLogout()
}

// MARK: - Presenter Protocol

protocol IHomePresenter {
    func viewDidLoad()
    func didSelectTab(_ tab: HomeTab)
    func didTapEvent(id: String)
    func didTapCreateEvent()
    func didTapFindEvents()
    func didTapLogout()
    func didConfirmLogout()
    func didPullToRefresh()
}

// MARK: - Implementation

final class HomePresenter {
    
    // MARK: - Properties
    
    weak var view: IHomeView?
    weak var output: IHomeOutput?
    
    private let service: IHomeService
    private let tokenStorage: ITokenStorage
    private let viewModelFactory: IHomeViewModelFactory
    
    private var selectedTab: HomeTab = .myEvents
    private var allEvents: [EventListItem] = []
    private var isLoading = false
    
    private var myEvents: [EventListItem] {
        allEvents.filter { $0.role == .admin || $0.role == .participant }
    }
    
    private var findEvents: [EventListItem] {
        allEvents
    }
    
    // MARK: - Init
    
    init(service: IHomeService, tokenStorage: ITokenStorage, viewModelFactory: IHomeViewModelFactory) {
        self.service = service
        self.tokenStorage = tokenStorage
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Private
    
    private func loadData() {
        isLoading = true
        updateView()
        
        Task { @MainActor in
            do {
                self.allEvents = try await service.fetchEvents()
            } catch {
                self.allEvents = []
            }
            
            self.isLoading = false
            self.updateView()
        }
    }
    
    private func updateView() {
        let viewModel = viewModelFactory.makeViewModel(
            selectedTab: selectedTab,
            myEvents: myEvents,
            findEvents: findEvents,
            isLoading: isLoading
        )
        view?.configure(with: viewModel)
    }
}

// MARK: - IHomePresenter

extension HomePresenter: IHomePresenter {
    
    func viewDidLoad() {
        loadData()
    }
    
    func didSelectTab(_ tab: HomeTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        updateView()
    }
    
    func didTapEvent(id: String) {
        output?.homeDidSelectEvent(eventId: id)
    }
    
    func didTapCreateEvent() {
        output?.homeDidTapCreateEvent()
    }
    
    func didTapFindEvents() {
        selectedTab = .findEvents
        updateView()
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func didConfirmLogout() {
        tokenStorage.clear()
        output?.homeDidTapLogout()
    }
    
    func didPullToRefresh() {
        loadData()
    }
}
