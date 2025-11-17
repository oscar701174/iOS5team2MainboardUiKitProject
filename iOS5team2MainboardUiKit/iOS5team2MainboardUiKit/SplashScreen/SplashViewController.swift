//
//  SplashViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by cheon on 11/17/25.
//

import UIKit

class SplashViewController: UIViewController {

    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IconBlack")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColor.menuIcon
        return imageView
    }()

    private func setupLayout() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = AppColor.background

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func switchToNextScreen() {
        let next: UIViewController

        if IntroPageViewController.shouldShowIntro() {
            next = IntroPageViewController()
        } else {
            next = MainViewController()
        }

        next.modalTransitionStyle = .crossDissolve
        next.modalPresentationStyle = .fullScreen
        present(next, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.switchToNextScreen()
        }
    }
}

#Preview {
    SplashViewController()
}
