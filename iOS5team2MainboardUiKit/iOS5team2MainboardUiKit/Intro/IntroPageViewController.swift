//
//  IntroPageViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

final class IntroPageViewController: UIPageViewController {

    private var pages: [UIViewController] = []
    private let indicator = UIPageControl()
    private var selectedLanguages = Set<String>()
    private var isSetupComplete = false

    static func shouldShowIntro() -> Bool {
        !UserDefaults.standard.bool(forKey: IntroModel.introSeenKey)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        view.backgroundColor = .systemBackground
        setupIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isSetupComplete else { return }
        setupPages()
        if let first = pages.first { setViewControllers([first], direction: .forward, animated: false) }
        isSetupComplete = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(indicator)
    }

    private func setupPages() {
        pages = IntroModel.pages.map(makeIntroPage)
        pages.append(makeLanguagePage())
    }

    private func setupIndicator() {
        indicator.numberOfPages = IntroModel.pages.count + 1
        indicator.pageIndicatorTintColor = .systemGray3
        indicator.currentPageIndicatorTintColor = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    private func makeIntroPage(from model: IntroModel.IntPage) -> UIViewController {
        let page = UIViewController()
        page.view.backgroundColor = model.backgroundColor

        let icon = UIImageView(image: UIImage(systemName: model.icon))
        icon.tintColor = model.fontColor
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = model.title
        title.font = model.titleFont
        title.textColor = model.fontColor
        title.textAlignment = .center
        title.numberOfLines = 1
        title.translatesAutoresizingMaskIntoConstraints = false

        let desc = UILabel()
        desc.text = model.description
        desc.font = model.descriptionFont
        desc.textColor = model.fontColor.withAlphaComponent(0.9)
        desc.textAlignment = .center
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [icon, title, desc])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        page.view.addSubview(stack)
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 140),
            icon.widthAnchor.constraint(equalToConstant: 140),
            stack.centerYAnchor.constraint(equalTo: page.view.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -28)
        ])

        return page
    }

    private func makeLanguagePage() -> UIViewController {
        let page = UIViewController()
        page.view.backgroundColor = .systemGray6

        let title = UILabel()
        title.text = "프로그래밍 언어를 최대 3개 선택하세요!"
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        title.textColor = .label
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = true

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 14
        grid.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(grid)

        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 8),
            grid.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            grid.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            grid.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        populateLanguages(in: grid)

        let start = UIButton(type: .system)
        start.setTitle("시작하기", for: .normal)
        start.titleLabel?.font = .boldSystemFont(ofSize: 18)
        start.backgroundColor = .systemBlue
        start.tintColor = .white
        start.layer.cornerRadius = 12
        start.layer.masksToBounds = true
        start.translatesAutoresizingMaskIntoConstraints = false
        start.heightAnchor.constraint(equalToConstant: 55).isActive = true
        start.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        [title, scroll, start].forEach { page.view.addSubview($0) }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -16),

            scroll.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 24),
            scroll.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 24),
            scroll.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -24),
            scroll.bottomAnchor.constraint(equalTo: start.topAnchor, constant: -40),

            start.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            start.bottomAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            start.widthAnchor.constraint(equalToConstant: 180)
        ])
        return page
    }

    private func populateLanguages(in grid: UIStackView) {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let columns = traitCollection.userInterfaceIdiom == .pad ? 3 : 2
        let buttons = IntroModel.languages.map(makeLanguageButton)

        stride(from: 0, to: buttons.count, by: columns).forEach { start in
            var row = Array(buttons[start..<min(start + columns, buttons.count)]) as [UIView]
            while row.count < columns { row.append(makeSpacer()) }

            let rowStack = UIStackView(arrangedSubviews: row)
            rowStack.axis = .horizontal
            rowStack.spacing = 14
            rowStack.distribution = .fillEqually

            row.forEach { $0.heightAnchor.constraint(equalToConstant: 90).isActive = true }
            grid.addArrangedSubview(rowStack)
        }
    }

    private func makeLanguageButton(for title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        if let image = UIImage(named: "\(title)Logo") {
            let smaller = image.preparingThumbnail(of: CGSize(width: 26, height: 26))
            config.image = smaller?.withRenderingMode(.alwaysOriginal)
        }
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.background.backgroundColor = .systemGray6
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        let attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .kern: -0.5
        ]))
        config.attributedTitle = attributedTitle

        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontSizeToFitWidth = false
        button.contentHorizontalAlignment = .leading
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12
        button.layer.borderColor = UIColor.systemGray3.cgColor

        button.configurationUpdateHandler = { button in
            guard let name = button.configuration?.title else { return }
            if self.selectedLanguages.contains(name) {
                button.configuration?.background.backgroundColor = .systemBlue
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.configuration?.baseForegroundColor = .white
            } else {
                button.configuration?.background.backgroundColor = .systemGray6
                button.layer.borderColor = UIColor.systemGray3.cgColor
                button.configuration?.baseForegroundColor = .label
            }
        }

        button.addAction(UIAction { [weak self] _ in
            self?.toggleLanguage(for: button)
        }, for: .touchUpInside)
        return button
    }

    private func toggleLanguage(for button: UIButton) {
        guard let name = button.configuration?.title else { return }
        let isSelected = selectedLanguages.contains(name)
        if isSelected {
            selectedLanguages.remove(name)
            button.configuration?.baseBackgroundColor = .systemGray6
            button.layer.borderColor = UIColor.systemGray3.cgColor
        } else if selectedLanguages.count < 3 {
            selectedLanguages.insert(name)
            button.configuration?.baseBackgroundColor = .systemBlue
            button.layer.borderColor = UIColor.systemBlue.cgColor
        }
        UserDefaults.standard.set(Array(selectedLanguages), forKey: "preferredLanguages")
    }

    @objc private func startTapped() {
        UserDefaults.standard.set(true, forKey: IntroModel.introSeenKey)
        dismiss(animated: true)
    }

    private func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.alpha = 0
        return spacer
    }
}

extension IntroPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = viewControllers?.first,
              let index = pages.firstIndex(of: current) else { return }
        indicator.currentPage = index
    }
}

#Preview {
    IntroPageViewController()
}
