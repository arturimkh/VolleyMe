//
//  EventDetailsPresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

// MARK: - View Protocol

protocol IEventDetailsView: AnyObject {
    func configure(with viewModel: EventDetailsViewModel)
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showAlert(_ viewModel: AlertViewModel, onCheckboxChanged: @escaping (Bool) -> Void, onPrimaryAction: @escaping () -> Void)
    func dismissAlert()
}

// MARK: - Output Protocol

protocol IEventDetailsOutput: AnyObject {
    func eventDetailsDidRequestClose()
    func eventDetailsDidCancelEvent()
}

// MARK: - Presenter Protocol

protocol IEventDetailsPresenter {
    func viewDidLoad()
    func didTapClose()
    func didTapMoreOptions()
    func didTapCopyAddress()
    func didToggleDescription()
    func didTapPrimaryAction()
    func didTapSecondaryAction()
    func didTapShareLink()
}

// MARK: - Implementation

final class EventDetailsPresenter {
    
    // MARK: - Properties
    
    weak var view: IEventDetailsView?
    weak var output: IEventDetailsOutput?
    
    private let eventId: String
    private let service: IEventDetailsService
    private let viewModelFactory: IEventDetailsViewModelFactory
    
    private var eventDetails: EventDetails?
    private var isDescriptionExpanded = false
    private var isLoading = false
    
    // MARK: - Init
    
    init(
        eventId: String,
        service: IEventDetailsService,
        viewModelFactory: IEventDetailsViewModelFactory
    ) {
        self.eventId = eventId
        self.service = service
        self.viewModelFactory = viewModelFactory
    }
}

// MARK: - IEventDetailsPresenter

extension EventDetailsPresenter: IEventDetailsPresenter {
    
    func viewDidLoad() {
        loadEventDetails()
    }
    
    func didTapClose() {
        output?.eventDetailsDidRequestClose()
    }
    
    func didTapMoreOptions() {
        // TODO: Показать меню с дополнительными опциями
    }
    
    func didTapCopyAddress() {
        guard let event = eventDetails else { return }
        UIPasteboard.general.string = "\(event.city), \(event.address)"
    }
    
    func didToggleDescription() {
        isDescriptionExpanded.toggle()
        updateView()
    }
    
    func didTapPrimaryAction() {
        guard let event = eventDetails else { return }
        
        switch event.userRole {
        case .viewer:
            handleJoinAction(event: event)
        case .participant:
            handleLeaveAction(event: event)
        case .host:
            handleCancelAction(event: event)
        }
    }
    
    func didTapSecondaryAction() {
        guard let event = eventDetails, event.userRole == .host else { return }
        shareInviteLink()
    }
    
    func didTapShareLink() {
        shareInviteLink()
    }
}

// MARK: - Private Methods

private extension EventDetailsPresenter {
    
    func loadEventDetails() {
        view?.showLoading()
        
        Task { @MainActor in
            do {
                let details = try await service.fetchEventDetails(eventId: eventId)
                self.eventDetails = details
                view?.hideLoading()
                updateView()
            } catch {
                view?.hideLoading()
                view?.showError(error.localizedDescription)
            }
        }
    }
    
    func updateView() {
        guard let event = eventDetails else { return }
        let viewModel = viewModelFactory.createViewModel(
            from: event,
            isDescriptionExpanded: isDescriptionExpanded,
            isLoading: isLoading
        )
        view?.configure(with: viewModel)
    }
    
    // MARK: - Actions
    
    func handleJoinAction(event: EventDetails) {
        if event.isFull {
            let alertVM = viewModelFactory.createFullEventAlertViewModel()
            view?.showAlert(alertVM, onCheckboxChanged: { _ in }, onPrimaryAction: { [weak self] in
                self?.view?.dismissAlert()
            })
            return
        }
        
        let alertVM = viewModelFactory.createJoinAlertViewModel()
        view?.showAlert(alertVM, onCheckboxChanged: { [weak self] isChecked in
            // Обновляем состояние кнопки в алерте
        }, onPrimaryAction: { [weak self] in
            self?.performJoin()
        })
    }
    
    func handleLeaveAction(event: EventDetails) {
        let isLessThan2Hours = event.startTime.timeIntervalSinceNow < 2 * 3600
        let alertVM = viewModelFactory.createLeaveAlertViewModel(isLessThan2Hours: isLessThan2Hours)
        
        view?.showAlert(alertVM, onCheckboxChanged: { _ in }, onPrimaryAction: { [weak self] in
            self?.performLeave()
        })
    }
    
    func handleCancelAction(event: EventDetails) {
        let isLessThan2Hours = event.startTime.timeIntervalSinceNow < 2 * 3600
        let hasParticipants = event.participants.count > 1 // Больше 1, т.к. сам хост тоже участник
        let alertVM = viewModelFactory.createCancelAlertViewModel(
            isLessThan2Hours: isLessThan2Hours,
            hasParticipants: hasParticipants
        )
        
        view?.showAlert(alertVM, onCheckboxChanged: { _ in }, onPrimaryAction: { [weak self] in
            self?.performCancel()
        })
    }
    
    func performJoin() {
        isLoading = true
        updateView()
        
        Task { @MainActor in
            do {
                try await service.joinEvent(eventId: eventId)
                isLoading = false
                view?.dismissAlert()
                loadEventDetails() // Перезагружаем данные
            } catch {
                isLoading = false
                updateView()
                view?.showError(error.localizedDescription)
            }
        }
    }
    
    func performLeave() {
        isLoading = true
        updateView()
        
        Task { @MainActor in
            do {
                try await service.leaveEvent(eventId: eventId)
                isLoading = false
                view?.dismissAlert()
                loadEventDetails() // Перезагружаем данные
            } catch {
                isLoading = false
                updateView()
                view?.showError(error.localizedDescription)
            }
        }
    }
    
    func performCancel() {
        isLoading = true
        updateView()
        
        Task { @MainActor in
            do {
                try await service.cancelEvent(eventId: eventId)
                isLoading = false
                view?.dismissAlert()
                output?.eventDetailsDidCancelEvent()
            } catch {
                isLoading = false
                updateView()
                view?.showError(error.localizedDescription)
            }
        }
    }
    
    func shareInviteLink() {
        // TODO: Реализовать шаринг ссылки
        let link = "https://volleyme.app/event/\(eventId)"
        UIPasteboard.general.string = link
    }
}

// MARK: - UIPasteboard import

import UIKit


