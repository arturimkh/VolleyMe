//
//  NewEventPresenter.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import Foundation

// MARK: - Protocols

protocol INewEventView: AnyObject {
    func configure(with viewModel: NewEventViewModel)
    func showError(_ message: String)
}

protocol INewEventOutput: AnyObject {
    func newEventDidFinish()
    func newEventDidCancel()
}

protocol INewEventPresenter {
    func viewDidLoad()
    func didTapBack()
    func didTapSubmit()
    
    // Text fields
    func didChangeTitle(_ text: String)
    func didClearTitle()
    func didChangeCity(_ text: String)
    func didClearCity()
    func didChangeAddress(_ text: String)
    func didClearAddress()
    func didChangePrice(_ text: String)
    func didChangeComment(_ text: String)
    
    // Date/Time
    func didChangeDate(_ date: Date)
    func didChangeStartTime(_ time: Date)
    func didChangeEndTime(_ time: Date)
    
    // Stepper
    func didIncrementParticipants()
    func didDecrementParticipants()
}

// MARK: - NewEventPresenter

final class NewEventPresenter: INewEventPresenter {
    
    // MARK: - Properties
    
    weak var view: INewEventView?
    weak var output: INewEventOutput?
    
    private let service: INewEventService
    private let viewModelFactory: INewEventViewModelFactory
    private var formData = NewEventFormData()
    
    /// Inline field errors (red borders) only after the user tries to submit an invalid form.
    private var showInlineValidationErrors = false
    
    // MARK: - Init
    
    init(service: INewEventService, viewModelFactory: INewEventViewModelFactory) {
        self.service = service
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - INewEventPresenter
    
    func viewDidLoad() {
        updateView()
    }
    
    func didTapBack() {
        output?.newEventDidCancel()
    }
    
    func didTapSubmit() {
        formData.validate()
        
        guard formData.isValid else {
            showInlineValidationErrors = true
            updateView()
            return
        }
        
        Task { @MainActor in
            do {
                let dto = formData.toDTO()
                try await service.createEvent(dto: dto)
                output?.newEventDidFinish()
            } catch {
                view?.showError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Text Fields
    
    func didChangeTitle(_ text: String) {
        formData.title = text
        updateView()
    }
    
    func didClearTitle() {
        formData.title = ""
        updateView()
    }
    
    func didChangeCity(_ text: String) {
        formData.city = text
        updateView()
    }
    
    func didClearCity() {
        formData.city = ""
        updateView()
    }
    
    func didChangeAddress(_ text: String) {
        formData.address = text
        updateView()
    }
    
    func didClearAddress() {
        formData.address = ""
        updateView()
    }
    
    func didChangePrice(_ text: String) {
        formData.price = text
        updateView()
    }
    
    func didChangeComment(_ text: String) {
        formData.comment = text
        updateView()
    }
    
    // MARK: - Date/Time
    
    func didChangeDate(_ date: Date) {
        formData.date = date
        updateView()
    }
    
    func didChangeStartTime(_ time: Date) {
        formData.startTime = time
        updateView()
    }
    
    func didChangeEndTime(_ time: Date) {
        formData.endTime = time
        updateView()
    }
    
    // MARK: - Stepper
    
    func didIncrementParticipants() {
        formData.maxParticipantsCount += 1
        updateView()
    }
    
    func didDecrementParticipants() {
        formData.maxParticipantsCount = max(1, formData.maxParticipantsCount - 1)
        updateView()
    }
    
    // MARK: - Private
    
    private func updateView() {
        formData.validate()
        let viewModel = viewModelFactory.makeViewModel(from: formData, showValidationErrors: showInlineValidationErrors)
        view?.configure(with: viewModel)
    }
}
