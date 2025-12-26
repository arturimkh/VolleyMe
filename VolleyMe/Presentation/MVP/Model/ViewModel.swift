//
//  ViewModel.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

/// Базовый протокол для ViewModel
/// ViewModel - это DTO (Data Transfer Object) для передачи данных в View
/// Каждый экран определяет свои ViewModels как структуры
/// Пример:
/// struct ProductItemViewModel {
///     let title: String
///     let subtitle: String
/// }
protocol BaseViewModel {}
