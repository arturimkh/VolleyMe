//
//  ViewModelFactoryProtocol.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

/// Базовый протокол для ViewModelFactory
/// Каждый экран определяет свой протокол IXxxViewModelFactory с нужными методами
/// Пример:
/// protocol IProductsListViewModelFactory {
///     func createViewModels(from models: [Product]) -> [ProductItemViewModel]
/// }
protocol BaseViewModelFactory {}
