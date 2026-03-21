//
//  NewEventViewModelFactory.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit

protocol INewEventViewModelFactory {
    func makeViewModel(from formData: NewEventFormData) -> NewEventViewModel
}

final class NewEventViewModelFactory: INewEventViewModelFactory {
    
    // MARK: - INewEventViewModelFactory
    
    func makeViewModel(from formData: NewEventFormData) -> NewEventViewModel {
        
        // Расчет продолжительности
        let durationInMinutes = Int(formData.endTime.timeIntervalSince(formData.startTime) / 60)
        let hours = durationInMinutes / 60
        let minutes = durationInMinutes % 60
        
        var durationText: String
        if durationInMinutes <= 0 {
            durationText = "Неверное время"
        } else if hours > 0 && minutes > 0 {
            durationText = "Продолжительность: \(hours) ч \(minutes) мин"
        } else if hours > 0 {
            durationText = "Продолжительность: \(hours) \(hourString(hours))"
        } else {
            durationText = "Продолжительность: \(minutes) мин"
        }
        
        return NewEventViewModel(
            titleField: FormTextFieldViewModel(
                placeholder: "Название встречи",
                text: formData.title,
                keyboardType: .default,
                icon: nil,
                showClearButton: true,
                isMultiline: false,
                hint: nil,
                errorMessage: formData.getError(for: .emptyTitle)
            ),
            dateField: FormDateFieldViewModel(
                label: "Дата",
                date: formData.date,
                icon: UIImage(systemName: "calendar"),
                errorMessage: nil
            ),
            startTimeField: FormTimeFieldViewModel(
                label: "Начало встречи",
                time: formData.startTime,
                icon: UIImage(systemName: "clock"),
                errorMessage: nil
            ),
            endTimeField: FormTimeFieldViewModel(
                label: "Окончание встречи",
                time: formData.endTime,
                icon: UIImage(systemName: "clock"),
                errorMessage: formData.getError(for: .invalidTimeRange)
            ),
            durationText: durationText,
            addressField: FormTextFieldViewModel(
                placeholder: "Адрес",
                text: formData.address,
                keyboardType: .default,
                icon: UIImage(systemName: "location"),
                showClearButton: true,
                isMultiline: false,
                hint: nil,
                errorMessage: formData.getError(for: .emptyAddress)
            ),
            participantCountField: FormStepperFieldViewModel(
                label: "Количество участников",
                value: formData.maxParticipantCount,
                minValue: 1,
                maxValue: 99,
                hint: "Максимальное количество участников, включая вас.",
                errorMessage: nil
            ),
            priceField: FormTextFieldViewModel(
                placeholder: "Стоимость",
                text: formData.price,
                keyboardType: .numberPad,
                icon: UIImage(systemName: "rublesign"),
                showClearButton: false,
                isMultiline: false,
                hint: "Укажите стоимость для одного участника, если встреча является платной. Например, если вы арендуете платную площадку.",
                errorMessage: formData.getError(for: .invalidPrice)
            ),
            commentField: FormTextFieldViewModel(
                placeholder: "Комментарий для участников",
                text: formData.comment,
                keyboardType: .default,
                icon: nil,
                showClearButton: false,
                isMultiline: true,
                hint: nil,
                errorMessage: nil
            ),
            submitButton: FormSubmitButtonViewModel(
                title: "Создать встречу",
                isEnabled: formData.isValid
            )
        )
    }
    
    // MARK: - Helpers
    
    private func hourString(_ hours: Int) -> String {
        switch hours {
        case 1:
            return "час"
        case 2, 3, 4:
            return "часа"
        default:
            return "часов"
        }
    }
}
