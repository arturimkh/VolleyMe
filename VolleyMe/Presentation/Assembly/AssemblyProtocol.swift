//
//  AssemblyProtocol.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

/// Базовый протокол для Assembly
/// Каждый экран определяет свой протокол IXxxAssembly с методом assemble()
/// Пример:
/// protocol IProductsListAssembly {
///     func assemble(with output: IProductsListOutput) -> UIViewController
/// }
protocol BaseAssembly {}


