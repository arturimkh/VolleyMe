//
//  CreateEventDTO.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 31.01.2026.
//

import Foundation

// MARK: - DTO for API

struct CreateEventDTO: Encodable {
    let title: String
    let date: String
    let startTime: String
    let endTime: String
    let address: String
    let maxParticipantCount: Int
    let price: Int?
    let comment: String?
}

// MARK: - Form Data

struct NewEventFormData {
    var title: String = ""
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date().addingTimeInterval(3600) // +1 hour
    var address: String = ""
    var maxParticipantCount: Int = 12
    var price: String = ""
    var comment: String = ""
    
    private(set) var validationErrors: Set<ValidationError> = []
    
    var isValid: Bool {
        validationErrors.isEmpty
    }
    
    // MARK: - Validation
    
    mutating func validate() {
        validationErrors.removeAll()
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.insert(.emptyTitle)
        }
        
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.insert(.emptyAddress)
        }
        
        if endTime <= startTime {
            validationErrors.insert(.invalidTimeRange)
        }
        
        if !price.isEmpty {
            if Int(price) == nil {
                validationErrors.insert(.invalidPrice)
            }
        }
    }
    
    func getError(for error: ValidationError) -> String? {
        validationErrors.contains(error) ? error.message : nil
    }
    
    // MARK: - Convert to DTO
    
    func toDTO() -> CreateEventDTO {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        return CreateEventDTO(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: dateFormatter.string(from: date),
            startTime: timeFormatter.string(from: startTime),
            endTime: timeFormatter.string(from: endTime),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            maxParticipantCount: maxParticipantCount,
            price: Int(price),
            comment: comment.isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

// MARK: - ValidationError

enum ValidationError: Hashable {
    case emptyTitle
    case emptyAddress
    case invalidTimeRange
    case invalidPrice
    
    var message: String {
        switch self {
        case .emptyTitle:
            return "Введите название встречи"
        case .emptyAddress:
            return "Введите адрес"
        case .invalidTimeRange:
            return "Время окончания должно быть позже времени начала"
        case .invalidPrice:
            return "Введите корректную цену"
        }
    }
}
