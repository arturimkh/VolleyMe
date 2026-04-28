//
//  HomeViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Main ViewModel

struct HomeViewModel {
    let header: HomeHeaderViewModel
    let tabs: [HomeTabViewModel]
    let selectedTab: HomeTab
    let content: HomeContentViewModel
}

// MARK: - Header

struct HomeHeaderViewModel {
    let avatarText: String
    let username: String
    let logoutTitle: String
}

// MARK: - Tab

struct HomeTabViewModel {
    let tab: HomeTab
    let title: String
    let icon: UIImage?
    let isSelected: Bool
}

// MARK: - Content

enum HomeContentViewModel {
    case loading
    case empty(EmptyStateViewModel)
    case events(EventListViewModel)
}

// MARK: - Empty State

struct EmptyStateViewModel {
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
    let primaryButtonIcon: UIImage?
    let secondaryButtonTitle: String?
    let secondaryButtonIcon: UIImage?
}

// MARK: - Event List

struct EventListViewModel {
    let showCreateButton: Bool
    let sections: [EventSectionViewModel]
}

// MARK: - Event Section

struct EventSectionViewModel {
    let title: String
    let count: Int
    let items: [EventCardViewModel]
}

// MARK: - Event Card

struct EventCardViewModel {
    let id: String
    let dateTimeText: String
    let subtitle: String
    let address: String
    let priceText: String
    let priceColor: UIColor
    let participantCountText: String
    let roleBadge: EventRoleBadgeViewModel?
    let isSelectable: Bool
}

// MARK: - Role Badge

struct EventRoleBadgeViewModel {
    let text: String
    let backgroundColor: UIColor
    let textColor: UIColor
}
