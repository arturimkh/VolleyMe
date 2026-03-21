//
//  NewEventViewModels.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import UIKit

// MARK: - Main ViewModel

struct NewEventViewModel {
    let titleField: FormTextFieldViewModel
    let dateField: FormDateFieldViewModel
    let startTimeField: FormTimeFieldViewModel
    let endTimeField: FormTimeFieldViewModel
    let durationText: String
    let addressField: FormTextFieldViewModel
    let participantCountField: FormStepperFieldViewModel
    let priceField: FormTextFieldViewModel
    let commentField: FormTextFieldViewModel
    let submitButton: FormSubmitButtonViewModel
}

// MARK: - FormTextFieldViewModel

struct FormTextFieldViewModel {
    let placeholder: String
    let text: String
    let keyboardType: UIKeyboardType
    let icon: UIImage?
    let showClearButton: Bool
    let isMultiline: Bool
    let hint: String?
    let errorMessage: String?
    
    init(
        placeholder: String,
        text: String = "",
        keyboardType: UIKeyboardType = .default,
        icon: UIImage? = nil,
        showClearButton: Bool = false,
        isMultiline: Bool = false,
        hint: String? = nil,
        errorMessage: String? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.keyboardType = keyboardType
        self.icon = icon
        self.showClearButton = showClearButton
        self.isMultiline = isMultiline
        self.hint = hint
        self.errorMessage = errorMessage
    }
}

// MARK: - FormDateFieldViewModel

struct FormDateFieldViewModel {
    let label: String
    let date: Date
    let icon: UIImage?
    let errorMessage: String?
    
    init(
        label: String,
        date: Date,
        icon: UIImage? = UIImage(systemName: "calendar"),
        errorMessage: String? = nil
    ) {
        self.label = label
        self.date = date
        self.icon = icon
        self.errorMessage = errorMessage
    }
}

// MARK: - FormTimeFieldViewModel

struct FormTimeFieldViewModel {
    let label: String
    let time: Date
    let icon: UIImage?
    let errorMessage: String?
    
    init(
        label: String,
        time: Date,
        icon: UIImage? = UIImage(systemName: "clock"),
        errorMessage: String? = nil
    ) {
        self.label = label
        self.time = time
        self.icon = icon
        self.errorMessage = errorMessage
    }
}

// MARK: - FormStepperFieldViewModel

struct FormStepperFieldViewModel {
    let label: String
    let value: Int
    let minValue: Int
    let maxValue: Int
    let hint: String?
    let errorMessage: String?
    
    init(
        label: String,
        value: Int,
        minValue: Int = 1,
        maxValue: Int = 99,
        hint: String? = nil,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.hint = hint
        self.errorMessage = errorMessage
    }
}

// MARK: - FormSubmitButtonViewModel

struct FormSubmitButtonViewModel {
    let title: String
    let isEnabled: Bool
    
    init(
        title: String,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.isEnabled = isEnabled
    }
}
