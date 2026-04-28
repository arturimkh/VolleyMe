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
    let startDt: String
    let endDt: String
    let city: String
    let address: String
    let maxParticipantsCount: Int
    let price: String
    let description: String
    let isPublic: Bool
    let imageUrls: [String]
    let country: String
    let currency: String
    let gameType: Int
    let formatType: Int
}

// MARK: - Form Data

struct NewEventFormData {
    var title: String = ""
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date().addingTimeInterval(3600)
    var city: String = ""
    var address: String = ""
    var maxParticipantsCount: Int = 12
    var price: String = ""
    var comment: String = ""
    var isPublic: Bool = true
    
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
        
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.insert(.emptyCity)
        }
        
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.insert(.emptyAddress)
        }
        
        if endTime <= startTime {
            validationErrors.insert(.invalidTimeRange)
        }
        
        if !price.isEmpty {
            if Double(price) == nil {
                validationErrors.insert(.invalidPrice)
            }
        }
    }
    
    func getError(for error: ValidationError) -> String? {
        validationErrors.contains(error) ? error.message : nil
    }
    
    // MARK: - Convert to DTO
    
    func toDTO() -> CreateEventDTO {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        
        let startDt = calendar.date(
            bySettingHour: startComponents.hour ?? 0,
            minute: startComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        let endDt = calendar.date(
            bySettingHour: endComponents.hour ?? 0,
            minute: endComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        let priceValue = price.isEmpty ? "0" : price
        let descriptionValue = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return CreateEventDTO(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDt: formatter.string(from: startDt),
            endDt: formatter.string(from: endDt),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            maxParticipantsCount: maxParticipantsCount,
            price: priceValue,
            description: descriptionValue,
            isPublic: isPublic,
            imageUrls: [],
            country: "RU",
            currency: "RUB",
            gameType: 0,
            formatType: 0
        )
    }
}

// MARK: - ValidationError

enum ValidationError: Hashable {
    case emptyTitle
    case emptyCity
    case emptyAddress
    case invalidTimeRange
    case invalidPrice
    
    var message: String {
        switch self {
        case .emptyTitle:
            return "Введите название встречи"
        case .emptyCity:
            return "Введите город"
        case .emptyAddress:
            return "Введите адрес"
        case .invalidTimeRange:
            return "Время окончания должно быть позже времени начала"
        case .invalidPrice:
            return "Введите корректную цену"
        }
    }
}
