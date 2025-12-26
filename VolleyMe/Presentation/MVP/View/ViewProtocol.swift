//
//  ViewProtocol.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

/// Базовый протокол для View
/// Каждый экран определяет свой протокол IXxxView с нужными методами
/// Пример:
/// protocol IProductsListView: AnyObject {
///     func configure()
///     func showLoading()
///     func hideLoading()
///     func showError(_ message: String)
/// }
protocol BaseView: AnyObject {}
