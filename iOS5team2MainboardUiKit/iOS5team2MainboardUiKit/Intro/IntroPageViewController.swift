//
//  IntroPageViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

/// # Overview
/// 앱 최초 실행 시 등장하는 **인트로 페이지 전체 흐름(UIPageViewController 기반)**를 관리하는 컨트롤러입니다.
///
/// # Discussion
/// 사용자가 앱의 주요 기능을 이해하도록 도와주는 여러 장의 소개 화면을 구성하며,
/// 마지막 페이지에서는 관심 카테고리 선택(최대 3개)이 가능합니다.
///
/// 동작 요약:
/// - IntroModel 기반 인트로 페이지 자동 생성
/// - 마지막 페이지: 관심 카테고리 선택 UI 제공
/// - 관심 카테고리 선택 후 “시작하기” → 메인 화면 진입
/// - 인트로는 최초 1회만 표시 (UserDefaults 저장)
///
/// 추가 지원 기능:
/// - 특정 상황에서 **마지막 페이지만 단독 표시**
/// - 페이지 이동 시 PageControl 연동
final class IntroPageViewController: UIPageViewController {

    // MARK: - Stored Properties

    /// 인트로 페이지를 구성하는 UIViewController 배열
    private var pages: [UIViewController] = []

    /// 현재 페이지 위치를 표시하는 UIPageControl
    private let indicator = UIPageControl()

    /// 사용자가 선택한 관심 카테고리 이름 목록(최대 3개)
    private var selectedNames = Set<String>()

    /// viewDidAppear에서 중복 setup 방지
    private var isSetupComplete = false

    /// true일 경우 마지막 카테고리 선택 페이지만 표시
    private var showLastOnly = false

    /// true일 경우 페이징 인디케이터 숨김
    private var shouldHideIndicator = false

    // MARK: - Static Logic

    /// 인트로를 보여줄지 여부 결정
    static func shouldShowIntro() -> Bool {
        !UserDefaults.standard.bool(forKey: IntroModel.introSeenKey)
    }

    /// 외부에서 호출해 “마지막 페이지 단독 표시” 모드 전환
    func showOnlyLastPage() {
        showLastOnly = true
        shouldHideIndicator = true
    }

    // MARK: - Life Cycle

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
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
        isSetupComplete = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(indicator)   // indicator가 가려지지 않도록
    }

    // MARK: - Page Setup

    /// 인트로 페이지들을 구성합니다.
    /// 마지막 페이지는 카테고리 선택 화면으로 고정됩니다.
    private func setupPages() {
        pages.removeAll()

        if showLastOnly {
            pages = [makeCategorySelectionPage()]
        } else {
            pages = IntroModel.pages.map(makeIntroPage)
            pages.append(makeCategorySelectionPage())
        }

        indicator.numberOfPages = pages.count
    }

    // MARK: - Page Indicator Setup

    private func setupIndicator() {
        guard !shouldHideIndicator else { return }

        indicator.pageIndicatorTintColor = .systemGray3
        indicator.currentPageIndicatorTintColor = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    // MARK: - Intro Page Builder

    /// 개별 인트로 페이지 UI를 구성합니다.
    private func makeIntroPage(from model: IntroModel.IntroPage) -> UIViewController {
        let page = UIViewController()
        page.view.backgroundColor = model.backgroundColor

        let icon = UIImageView(image: UIImage(named: model.icon))
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
            icon.heightAnchor.constraint(equalToConstant: 240),
            icon.widthAnchor.constraint(equalToConstant: 240),

            stack.centerYAnchor.constraint(equalTo: page.view.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -28)
        ])

        return page
    }

    // MARK: - Category Selection Page

    /// 관심 카테고리 선택 화면 구성
    private func makeCategorySelectionPage() -> UIViewController {
        let page = UIViewController()
        page.view.backgroundColor = .systemGray6

        let title = UILabel()
        title.text = "관심분야를 최대 3개 선택하세요!"
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

        populateCategories(in: grid)

        let start = UIButton(type: .system)
        start.setTitle("시작하기", for: .normal)
        start.titleLabel?.font = .boldSystemFont(ofSize: 18)
        start.backgroundColor = .systemBlue
        start.tintColor = .white
        start.layer.cornerRadius = 12
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

    // MARK: - 카테고리 버튼 생성

    private func populateCategories(in grid: UIStackView) {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let columns = traitCollection.userInterfaceIdiom == .pad ? 3 : 2
        let buttons = CategoryRepository.allCategories.map(makeCategoryButton)

        stride(from: 0, to: buttons.count, by: columns).forEach { start in
            var row = Array(buttons[start..<min(start + columns, buttons.count)])

            // 빈 공간 채우기
            while row.count < columns {
                row.append(makeSpacer())
            }

            let rowStack = UIStackView(arrangedSubviews: row)
            rowStack.axis = .horizontal
            rowStack.spacing = 14
            rowStack.distribution = .fillEqually

            row.forEach { $0.heightAnchor.constraint(equalToConstant: 90).isActive = true }

            grid.addArrangedSubview(rowStack)
        }
    }

    private func makeCategoryButton(for category: Category) -> UIButton {
        let title = category.name
        var config = UIButton.Configuration.plain()

        if let image = UIImage(named: category.iconName) {
            let thumbnail = image.preparingThumbnail(of: CGSize(width: 26, height: 26))
            config.image = thumbnail?.withRenderingMode(.alwaysOriginal)
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

        /// 선택 상태 UI 업데이트
        button.configurationUpdateHandler = { [weak self] btn in
            guard let self = self,
                  let name = btn.configuration?.title else { return }

            if self.selectedNames.contains(name) {
                btn.configuration?.background.backgroundColor = .systemBlue
                btn.layer.borderColor = UIColor.systemBlue.cgColor
                btn.configuration?.baseForegroundColor = .white
            } else {
                btn.configuration?.background.backgroundColor = .systemGray6
                btn.layer.borderColor = UIColor.systemGray3.cgColor
                btn.configuration?.baseForegroundColor = .label
            }
        }

        button.addAction(UIAction { [weak self] _ in
            self?.toggleCategory(for: button)
        }, for: .touchUpInside)

        return button
    }

    // MARK: - 카테고리 선택 토글

    private func toggleCategory(for button: UIButton) {
        guard let name = button.configuration?.title else { return }

        let isSelected = selectedNames.contains(name)

        if isSelected {
            selectedNames.remove(name)
        } else if selectedNames.count < 3 {
            selectedNames.insert(name)
        }

        UserDefaults.standard.set(Array(selectedNames), forKey: "preferredCategories")
        button.setNeedsUpdateConfiguration()
    }

    // MARK: - “시작하기” 버튼 동작

    @objc private func startTapped() {
        let selected = Array(selectedNames)
        WeightStore.shared.boost(selected, by: 300)

        UserDefaults.standard.set(true, forKey: IntroModel.introSeenKey)

        let main = MainViewController()
        main.modalTransitionStyle = .crossDissolve
        main.modalPresentationStyle = .fullScreen
        present(main, animated: true)
    }

    // MARK: - Spacer (빈 칸 대체용 버튼)

    private func makeSpacer() -> UIButton {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.layer.borderWidth = 0
        return button
    }
}

// MARK: - PageViewController Delegate/DataSource

extension IntroPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController),
              index > 0 else { return nil }

        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController),
              index < pages.count - 1 else { return nil }

        return pages[index + 1]
    }

    /// 페이지 스와이프 완료 후 PageControl 갱신
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
