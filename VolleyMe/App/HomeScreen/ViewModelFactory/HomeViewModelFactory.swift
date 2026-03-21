//
//  HomeViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit

// MARK: - Protocol

protocol IHomeViewModelFactory {
    func makeViewModel(
        selectedTab: HomeTab,
        myEvents: [EventListItem],
        findEvents: [EventListItem],
        isLoading: Bool
    ) -> HomeViewModel
}

// MARK: - Implementation

final class HomeViewModelFactory: IHomeViewModelFactory {
    
    // MARK: - Date Formatters
    
    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE, d MMMM, HH:mm"
        return f
    }()
    
    // MARK: - IHomeViewModelFactory
    
    func makeViewModel(
        selectedTab: HomeTab,
        myEvents: [EventListItem],
        findEvents: [EventListItem],
        isLoading: Bool
    ) -> HomeViewModel {
        let tabs = HomeTab.allCases.map { tab in
            HomeTabViewModel(
                tab: tab,
                title: tabTitle(for: tab, myCount: myEvents.count),
                icon: UIImage(systemName: tab.icon),
                isSelected: tab == selectedTab
            )
        }
        
        let content: HomeContentViewModel
        if isLoading {
            content = .loading
        } else {
            let events = selectedTab == .myEvents ? myEvents : findEvents
            if events.isEmpty {
                content = .empty(makeEmptyState(for: selectedTab))
            } else {
                content = .events(makeEventList(events: events, tab: selectedTab))
            }
        }
        
        return HomeViewModel(
            header: HomeHeaderViewModel(
                avatarText: "U",
                username: "username",
                logoutTitle: "Выйти"
            ),
            tabs: tabs,
            selectedTab: selectedTab,
            content: content
        )
    }
    
    // MARK: - Private Helpers
    
    private func tabTitle(for tab: HomeTab, myCount: Int) -> String {
        switch tab {
        case .myEvents:
            return "\(tab.title)  \(myCount)"
        case .findEvents:
            return tab.title
        }
    }
    
    private func makeEmptyState(for tab: HomeTab) -> EmptyStateViewModel {
        switch tab {
        case .myEvents:
            return EmptyStateViewModel(
                title: "У вас нет\nпредстоящих встреч",
                subtitle: "Найдите или создайте свою встречу.",
                primaryButtonTitle: "Создать встречу",
                primaryButtonIcon: UIImage(systemName: "plus.circle.fill"),
                secondaryButtonTitle: "Найти встречу",
                secondaryButtonIcon: UIImage(systemName: "magnifyingglass")
            )
        case .findEvents:
            return EmptyStateViewModel(
                title: "Нет предстоящих встреч",
                subtitle: "Будьте первым, кто создаст встречу.",
                primaryButtonTitle: "Создать встречу",
                primaryButtonIcon: UIImage(systemName: "plus.circle.fill"),
                secondaryButtonTitle: nil,
                secondaryButtonIcon: nil
            )
        }
    }
    
    private func makeEventList(events: [EventListItem], tab: HomeTab) -> EventListViewModel {
        let grouped = groupBySection(events)
        let sections = EventSection.allCases.compactMap { section -> EventSectionViewModel? in
            guard let items = grouped[section], !items.isEmpty else { return nil }
            return EventSectionViewModel(
                title: section.title,
                count: items.count,
                items: items.map { makeCardViewModel(from: $0) }
            )
        }
        return EventListViewModel(
            showCreateButton: tab == .myEvents,
            sections: sections
        )
    }
    
    private func groupBySection(_ events: [EventListItem]) -> [EventSection: [EventListItem]] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let startOfDayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: startOfToday)!
        
        var result: [EventSection: [EventListItem]] = [:]
        
        for event in events {
            let eventDay = calendar.startOfDay(for: event.dateTime)
            if eventDay >= startOfToday && eventDay < startOfTomorrow {
                result[.today, default: []].append(event)
            } else if eventDay >= startOfTomorrow && eventDay < startOfDayAfterTomorrow {
                result[.tomorrow, default: []].append(event)
            } else if eventDay >= startOfDayAfterTomorrow {
                result[.later, default: []].append(event)
            }
        }
        
        return result
    }
    
    private func makeCardViewModel(from item: EventListItem) -> EventCardViewModel {
        let dateText = dayFormatter.string(from: item.dateTime)
        
        let priceText: String
        let priceColor: UIColor
        if item.price == "0" || item.price.isEmpty {
            priceText = "Бесплатно"
            priceColor = .systemBlue
        } else {
            priceText = "\(item.price) \u{20BD}"
            priceColor = .systemBlue
        }
        
        let badge: EventRoleBadgeViewModel?
        switch item.role {
        case .admin:
            badge = EventRoleBadgeViewModel(
                text: "Вы – организатор",
                backgroundColor: UIColor.systemBlue.withAlphaComponent(0.15),
                textColor: .systemBlue
            )
        case .participant:
            badge = EventRoleBadgeViewModel(
                text: "Вы – участник",
                backgroundColor: UIColor.systemGreen.withAlphaComponent(0.15),
                textColor: .systemGreen
            )
        case .nobody:
            badge = nil
        }
        
        return EventCardViewModel(
            id: item.id,
            dateTimeText: dateText,
            subtitle: item.subtitle,
            address: item.address,
            priceText: priceText,
            priceColor: priceColor,
            participantCountText: "\(item.participantCount)",
            roleBadge: badge
        )
    }
}
