//
//  SceneDelegate.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 26.12.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Создание window программно
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Инициализация AppCoordinator
        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator
        
        // Запуск координатора
        coordinator.start()
    }
}

