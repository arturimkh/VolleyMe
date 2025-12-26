//
//  PresenterProtocol.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import Foundation

/// Базовый протокол для Presenter
/// Каждый экран определяет свой протокол IXxxPresenter с нужными методами
protocol PresenterLifecycle {
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
}

/// Default implementation - методы опциональны
extension PresenterLifecycle {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewDidAppear() {}
    func viewWillDisappear() {}
    func viewDidDisappear() {}
}
