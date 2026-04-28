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
    func showError(_ message: String)
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
    func viewWillAppear()
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
    private let logoutService: ILogoutService
    private let viewModelFactory: IHomeViewModelFactory
    
    private var selectedTab: HomeTab = .myEvents
    private var allEvents: [EventListItem] = []
    private var isLoading = false
    private var isFirstAppear = true
    
    private var myEvents: [EventListItem] {
        allEvents.filter { $0.role == .host || $0.role == .participant }
    }
    
    private var findEvents: [EventListItem] {
        allEvents
    }
    
    // MARK: - Init
    
    init(
        service: IHomeService,
        tokenStorage: ITokenStorage,
        logoutService: ILogoutService,
        viewModelFactory: IHomeViewModelFactory
    ) {
        self.service = service
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Private
    
    private func loadData() {
        isLoading = true
        updateView()
        
        Task { @MainActor in
            do {
                self.allEvents = try await service.fetchEvents(onlyMine: false)
            } catch {
                self.allEvents = []
                self.isLoading = false
                self.updateView()
                self.view?.showError(error.localizedDescription)
                return
            }
            
            self.isLoading = false
            self.updateView()
        }
    }
    
    private func updateView() {
        let viewModel = viewModelFactory.makeViewModel(
            selectedTab: selectedTab,
            userEmail: tokenStorage.tokens?.displayEmail,
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
    
    func viewWillAppear() {
        if isFirstAppear {
            isFirstAppear = false
            return
        }
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
        Task { @MainActor in
            // Best-effort: notify the backend so the refresh token is invalidated.
            // Local cleanup must run regardless of network/server failures so the
            // user always lands on the auth screen after confirming logout.
            try? await logoutService.logout()
            tokenStorage.clear()
            output?.homeDidTapLogout()
        }
    }
    
    func didPullToRefresh() {
        loadData()
    }
}
