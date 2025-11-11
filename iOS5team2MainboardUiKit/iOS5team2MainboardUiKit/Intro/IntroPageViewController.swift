//
//  IntroPageViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

final class IntroPageViewController: UIViewController {
    private let model: IntroModel
    private let icon = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    init(model: IntroModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = model.backgroundColor
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        icon.image = UIImage(systemName: model.icon)
        icon.contentMode = .scaleAspectFit

        titleLabel.text = model.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        descriptionLabel.text = model.description
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 120),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
