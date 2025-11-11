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
    private let prefKey = "preferredLanguages"
    private var selectedLanguages = Set<String>()

    static func shouldShowIntro() -> Bool {
        return !UserDefaults.standard.bool(forKey: IntroModel.introSeenKey)
    }

    private func markIntroAsSeen() {
        UserDefaults.standard.set(true, forKey: IntroModel.introSeenKey)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        configurePages()
        configureIndicator()
        setViewControllers([pages.first!], direction: .forward, animated: false)
    }

    private func configurePages() {
        pages = IntroModel.pages.map { model in
            let uvc = UIViewController()
            uvc.view.backgroundColor = model.background

            let icon = UIImageView(image: UIImage(systemName: model.icon))
            icon.contentMode = .scaleAspectFit

            let title = UILabel()
            title.text = model.title
            title.font = .systemFont(ofSize: 28, weight: .bold)
            title.textAlignment = .center

            let desc = UILabel()
            desc.text = model.description
            desc.font = .systemFont(ofSize: 16)
            desc.numberOfLines = 0
            desc.textAlignment = .center

            let stack = UIStackView(arrangedSubviews: [icon, title, desc])
            stack.axis = .vertical
            stack.spacing = 20
            stack.translatesAutoresizingMaskIntoConstraints = false
            uvc.view.addSubview(stack)

            NSLayoutConstraint.activate([
                icon.heightAnchor.constraint(equalToConstant: 120),
                stack.centerYAnchor.constraint(equalTo: uvc.view.centerYAnchor),
                stack.leadingAnchor.constraint(equalTo: uvc.view.leadingAnchor, constant: 24),
                stack.trailingAnchor.constraint(equalTo: uvc.view.trailingAnchor, constant: -24)
            ])

            return uvc
        }

        let langVC = UIViewController()
        langVC.view.backgroundColor = .systemGray6
        langVC.view.addSubview(languageSelectionView)
        NSLayoutConstraint.activate([
            languageSelectionView.centerYAnchor.constraint(equalTo: langVC.view.centerYAnchor),
            languageSelectionView.leadingAnchor.constraint(equalTo: langVC.view.leadingAnchor, constant: 24),
            languageSelectionView.trailingAnchor.constraint(equalTo: langVC.view.trailingAnchor, constant: -24)
        ])
        pages.append(langVC)
    }

    private func configureIndicator() {
        indicator.numberOfPages = pages.count
        indicator.pageIndicatorTintColor = .systemGray3
        indicator.currentPageIndicatorTintColor = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private lazy var languageSelectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "선호 언어를 최대 3개 선택하세요"
        title.font = .systemFont(ofSize: 18, weight: .medium)
        title.textAlignment = .center

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true

        let buttonStack = UIStackView(arrangedSubviews: IntroModel.languages.map(createLanguageButton))
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            buttonStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let start = UIButton(type: .system)
        start.setTitle("시작", for: .normal)
        start.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        start.backgroundColor = .systemBlue
        start.tintColor = .white
        start.layer.cornerRadius = 10
        start.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        let container = UIStackView(arrangedSubviews: [title, scrollView, start])
        container.axis = .vertical
        container.spacing = 30
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()

    private func createLanguageButton(for name: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(name, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.addTarget(self, action: #selector(languageTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func languageTapped(_ sender: UIButton) {
        guard let name = sender.title(for: .normal) else { return }
        if selectedLanguages.contains(name) {
            selectedLanguages.remove(name)
            sender.backgroundColor = .clear
        } else if selectedLanguages.count < 3 {
            selectedLanguages.insert(name)
            sender.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        }
        UserDefaults.standard.set(Array(selectedLanguages), forKey: prefKey)
    }

    @objc private func startTapped() {
        markIntroAsSeen()
        dismiss(animated: true)
    }
}

extension IntroPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController), pageIndex > 0 else { return nil }
        return pages[pageIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController), pageIndex < pages.count - 1 else { return nil }
        return pages[pageIndex + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = viewControllers?.first,
              let index = pages.firstIndex(of: current)
        else { return }
        indicator.currentPage = index
    }
}

#Preview(){
    MainViewController()
}
