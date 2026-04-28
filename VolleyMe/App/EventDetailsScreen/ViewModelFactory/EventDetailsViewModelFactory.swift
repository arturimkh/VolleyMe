//
//  EventDetailsViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

// MARK: - Protocol

protocol IEventDetailsViewModelFactory {
    func createViewModel(from event: EventDetails, isDescriptionExpanded: Bool, isLoading: Bool) -> EventDetailsViewModel
    func createJoinAlertViewModel() -> AlertViewModel
    func createLeaveAlertViewModel(isLessThan2Hours: Bool) -> AlertViewModel
    func createCancelAlertViewModel(isLessThan2Hours: Bool, hasParticipants: Bool) -> AlertViewModel
    func createFullEventAlertViewModel() -> AlertViewModel
}

// MARK: - Implementation

final class EventDetailsViewModelFactory: IEventDetailsViewModelFactory {
    
    // MARK: - Constants
    
    private enum Constants {
        static let descriptionPreviewLength = 100
        static let currentUserSuffix = ""
    }
    
    // MARK: - IEventDetailsViewModelFactory
    
    func createViewModel(
        from event: EventDetails,
        isDescriptionExpanded: Bool,
        isLoading: Bool
    ) -> EventDetailsViewModel {
        EventDetailsViewModel(
            title: event.title,
            roleBadge: createRoleBadge(for: event.userRole),
            infoItems: createInfoItems(from: event),
            description: createDescription(from: event.description, isExpanded: isDescriptionExpanded),
            participantsSection: createParticipantsSection(
                participants: event.participants,
                maxCount: event.maxParticipantsCount
            ),
            hostsSection: createHostsSection(hosts: event.hosts),
            actionButton: createPrimaryActionButton(for: event.userRole, isFull: event.isFull, isLoading: isLoading),
            secondaryActionButton: createSecondaryActionButton(for: event.userRole),
            userRole: event.userRole,
            isFull: event.isFull
        )
    }
    
    func createJoinAlertViewModel() -> AlertViewModel {
        return AlertViewModel(
            title: "Предупреждение",
            message: "Уведомления пользователей находятся в разработке.\n\nЕсли позднее вы решите покинуть встречу, пожалуйста, уведомите об этом организатора встречи самостоятельно.",
            checkboxText: "Я ознакомился(-ась) с предупреждением.",
            primaryAction: AlertAction(title: "Подтвердить и присоединиться", style: .default, isEnabled: false),
            secondaryAction: nil,
            cancelAction: AlertAction(title: "Отменить", style: .cancel)
        )
    }
    
    func createLeaveAlertViewModel(isLessThan2Hours: Bool) -> AlertViewModel {
        let title = isLessThan2Hours ? "До начала встречи менее 2-х часов" : "Покинуть встречу?"
        let message = "Уведомления пользователей находятся в разработке.\n\nЕсли вы решили покинуть встречу, пожалуйста, уведомите об этом организатора встречи самостоятельно."
        
        return AlertViewModel(
            title: title,
            message: message,
            checkboxText: "Я уведомил(-а) организатора о том, что покидаю встречу.",
            primaryAction: AlertAction(title: "Подтвердить и покинуть встречу", style: .destructive, isEnabled: false),
            secondaryAction: AlertAction(title: "Не покидать встречу", style: .default),
            cancelAction: AlertAction(title: "Отменить", style: .cancel)
        )
    }
    
    func createCancelAlertViewModel(isLessThan2Hours: Bool, hasParticipants: Bool) -> AlertViewModel {
        let title = isLessThan2Hours ? "До начала встречи менее 2-х часов" : "Отменить встречу?"
        
        if !hasParticipants {
            return AlertViewModel(
                title: "Отменить встречу?",
                message: nil,
                checkboxText: nil,
                primaryAction: AlertAction(title: "Отменить встречу", style: .destructive),
                secondaryAction: AlertAction(title: "Не отменять встречу", style: .default),
                cancelAction: AlertAction(title: "Отменить", style: .cancel)
            )
        }
        
        let message = "Уведомления пользователей находятся в разработке.\n\nЕсли вы решили отменить встречу, пожалуйста, уведомите об этом участников встречи самостоятельно."
        
        return AlertViewModel(
            title: title,
            message: message,
            checkboxText: "Я уведомил(-а) всех участников об отмене встречи.",
            primaryAction: AlertAction(title: "Подтвердить и отменить встречу", style: .destructive, isEnabled: false),
            secondaryAction: AlertAction(title: "Не отменять встречу", style: .default),
            cancelAction: AlertAction(title: "Отменить", style: .cancel)
        )
    }
    
    func createFullEventAlertViewModel() -> AlertViewModel {
        return AlertViewModel(
            title: "Все места заняты",
            message: "Простите, но вы не можете присоединиться к этой встрече сейчас.",
            checkboxText: nil,
            primaryAction: AlertAction(title: "OK", style: .default),
            secondaryAction: nil,
            cancelAction: AlertAction(title: "Отменить", style: .cancel)
        )
    }
    
    // MARK: - Private Methods
    
    private func createRoleBadge(for role: UserRole) -> RoleBadgeViewModel? {
        switch role {
        case .viewer:
            return nil
        case .participant:
            return RoleBadgeViewModel(
                text: "Вы – участник",
                backgroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0),
                textColor: .white
            )
        case .host:
            return RoleBadgeViewModel(
                text: "Вы – организатор встречи",
                backgroundColor: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
                textColor: .white
            )
        }
    }
    
    private func createInfoItems(from event: EventDetails) -> [EventInfoItemViewModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        // Дата
        dateFormatter.dateFormat = "d MMMM, yyyy"
        let dateString = dateFormatter.string(from: event.date)
        
        // Время
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: event.startTime)
        let endTimeString = dateFormatter.string(from: event.endTime)
        let timeString = "с \(startTimeString) до \(endTimeString)"
        
        // Продолжительность
        let hours = Int(event.duration) / 3600
        let minutes = (Int(event.duration) % 3600) / 60
        let durationString: String
        if minutes > 0 {
            durationString = "Продолжительность: \(hours) ч \(minutes) мин"
        } else {
            durationString = "Продолжительность: \(hours) ч"
        }
        
        // Адрес
        let addressString = "\(event.city),\n\(event.address)"
        
        // Цена
        let priceString = "\(event.price) \(event.currency)"
        
        return [
            EventInfoItemViewModel(
                icon: UIImage(systemName: "calendar"),
                text: dateString
            ),
            EventInfoItemViewModel(
                icon: UIImage(systemName: "clock"),
                text: timeString
            ),
            EventInfoItemViewModel(
                icon: UIImage(systemName: "timer"),
                text: durationString
            ),
            EventInfoItemViewModel(
                icon: UIImage(systemName: "mappin.circle"),
                text: addressString,
                showCopyButton: true
            ),
            EventInfoItemViewModel(
                icon: UIImage(systemName: "rublesign.circle"),
                text: priceString
            )
        ]
    }
    
    private func createDescription(from text: String, isExpanded: Bool) -> DescriptionViewModel {
        let shouldShowToggle = text.count > Constants.descriptionPreviewLength
        
        let previewText: String
        if shouldShowToggle && !isExpanded {
            let index = text.index(text.startIndex, offsetBy: min(Constants.descriptionPreviewLength, text.count))
            previewText = String(text[..<index]) + "..."
        } else {
            previewText = text
        }
        
        return DescriptionViewModel(
            fullText: text,
            previewText: previewText,
            isExpanded: isExpanded,
            showToggleButton: shouldShowToggle
        )
    }
    
    private func createParticipantsSection(
        participants: [Participant],
        maxCount: Int
    ) -> ParticipantsSectionViewModel {
        let cellViewModels = participants.map { participant in
            let displayName = participant.name ?? "Участник"
            return ParticipantCellViewModel(
                id: participant.id,
                avatarText: String(displayName.prefix(1).uppercased()),
                avatarUrl: participant.avatarUrl,
                name: displayName
            )
        }
        
        return ParticipantsSectionViewModel(
            title: "Участники",
            countText: "\(participants.count)/\(maxCount)",
            participants: cellViewModels
        )
    }
    
    private func createHostsSection(hosts: [Participant]) -> ParticipantsSectionViewModel {
        let cellViewModels = hosts.map { host in
            let displayName = host.name ?? "Организатор"
            return ParticipantCellViewModel(
                id: host.id,
                avatarText: String(displayName.prefix(1).uppercased()),
                avatarUrl: host.avatarUrl,
                name: displayName
            )
        }
        
        return ParticipantsSectionViewModel(
            title: "Организаторы",
            countText: "\(hosts.count)",
            participants: cellViewModels
        )
    }
    
    private func createPrimaryActionButton(for role: UserRole, isFull: Bool, isLoading: Bool) -> ActionButtonViewModel {
        switch role {
        case .viewer:
            if isFull {
                return ActionButtonViewModel(
                    title: "Все места заняты",
                    style: .disabled,
                    isEnabled: false
                )
            }
            return ActionButtonViewModel(
                title: "Присоединиться",
                style: .primary,
                isEnabled: !isLoading,
                showLoadingIndicator: isLoading
            )
        case .participant:
            return ActionButtonViewModel(
                title: "Покинуть встречу",
                style: .destructive,
                isEnabled: !isLoading,
                showLoadingIndicator: isLoading
            )
        case .host:
            return ActionButtonViewModel(
                title: "Отменить встречу",
                style: .destructive,
                isEnabled: !isLoading,
                showLoadingIndicator: isLoading
            )
        }
    }
    
    private func createSecondaryActionButton(for role: UserRole) -> ActionButtonViewModel? {
        guard role == .host else { return nil }
        
        return ActionButtonViewModel(
            title: "Ссылка-приглашение",
            style: .secondary,
            icon: UIImage(systemName: "link")
        )
    }
}



