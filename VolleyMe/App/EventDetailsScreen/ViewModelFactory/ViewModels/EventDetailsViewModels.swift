//
//  EventDetailsViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

// MARK: - Main ViewModel

struct EventDetailsViewModel {
    let title: String
    let roleBadge: RoleBadgeViewModel?
    let infoItems: [EventInfoItemViewModel]
    let description: DescriptionViewModel
    let participantsSection: ParticipantsSectionViewModel
    let hostsSection: ParticipantsSectionViewModel
    let actionButton: ActionButtonViewModel
    let secondaryActionButton: ActionButtonViewModel?
    let userRole: UserRole
    let isFull: Bool
}

// MARK: - Role Badge

struct RoleBadgeViewModel {
    let text: String
    let backgroundColor: UIColor
    let textColor: UIColor
}

// MARK: - Info Item

struct EventInfoItemViewModel {
    let icon: UIImage?
    let text: String
    let secondaryText: String?
    let showCopyButton: Bool
    
    init(icon: UIImage?, text: String, secondaryText: String? = nil, showCopyButton: Bool = false) {
        self.icon = icon
        self.text = text
        self.secondaryText = secondaryText
        self.showCopyButton = showCopyButton
    }
}

// MARK: - Description

struct DescriptionViewModel {
    let fullText: String
    let previewText: String
    let isExpanded: Bool
    let showToggleButton: Bool
}

// MARK: - Participants Section

struct ParticipantsSectionViewModel {
    let title: String
    let countText: String
    let participants: [ParticipantCellViewModel]
}

// MARK: - Participant Cell

struct ParticipantCellViewModel {
    let id: String
    let avatarText: String
    let avatarUrl: String?
    let name: String
    let isCurrentUser: Bool
    let currentUserSuffix: String?
}

// MARK: - Action Button

struct ActionButtonViewModel {
    let title: String
    let style: ButtonStyle
    let isEnabled: Bool
    let showLoadingIndicator: Bool
    let icon: UIImage?
    
    enum ButtonStyle {
        case primary      // Зелёная кнопка
        case secondary    // Синяя кнопка
        case destructive  // Красная кнопка
        case disabled     // Серая кнопка
    }
    
    init(
        title: String,
        style: ButtonStyle,
        isEnabled: Bool = true,
        showLoadingIndicator: Bool = false,
        icon: UIImage? = nil
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.showLoadingIndicator = showLoadingIndicator
        self.icon = icon
    }
}

// MARK: - Alert ViewModels

struct AlertViewModel {
    let title: String
    let message: String?
    let checkboxText: String?
    let primaryAction: AlertAction
    let secondaryAction: AlertAction?
    let cancelAction: AlertAction
}

struct AlertAction {
    let title: String
    let style: ActionStyle
    let isEnabled: Bool
    
    enum ActionStyle {
        case destructive
        case `default`
        case cancel
    }
    
    init(title: String, style: ActionStyle = .default, isEnabled: Bool = true) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
    }
}

