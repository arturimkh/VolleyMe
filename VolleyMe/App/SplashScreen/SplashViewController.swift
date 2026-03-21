//
//  SplashViewController.swift
//  VolleyMe
//
//  Created by Artur Imanbaev on 12.03.2026.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let logoSize: CGFloat = 120
        static let animationDuration: TimeInterval = 0.6
        static let displayDuration: TimeInterval = 1.8
    }
    
    // MARK: - UI Elements
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IconBall")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        label.text = "Версия \(version) – Базовый минимум"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    
    var onFinished: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAndFinish()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoImageView)
        view.addSubview(versionLabel)
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constants.logoSize)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        versionLabel.alpha = 0
    }
    
    // MARK: - Animation
    
    private func animateAndFinish() {
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
            self.versionLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayDuration) {
                self.onFinished?()
            }
        }
    }
}
