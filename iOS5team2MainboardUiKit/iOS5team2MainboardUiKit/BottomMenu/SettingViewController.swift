//
//  SettingViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/12/25.
//

import UIKit
import SwiftUI

/// # SettingSection
/// 설정 화면의 섹션 단위를 정의합니다.
struct SettingSection {
    let title: String
    let items: [SettingItem]
}

/// # SettingItem
/// 설정 화면의 각 항목 정보를 나타냅니다.
struct SettingItem {
    let title: String
    let icon: String
    let action: SettingAction
}

/// # SettingAction
/// 설정 항목 클릭 시 수행할 동작 열거형
enum SettingAction {
    case language, playback, tag, intro, about
}

/// # SettingViewController
/// 앱의 설정을 구성하고 보여주는 메인 설정 화면입니다.
///
/// - 섹션별 설정 항목을 테이블로 구성
/// - 각 항목 클릭 시 적절한 액션 수행
/// - `TagViewController`, `IntroPageViewController` 등으로 이동 가능
final class SettingViewController: UIViewController {

    /// 설정 항목을 표시하는 테이블뷰
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    /// 설정 항목 및 섹션 구성 데이터
    private let settings: [SettingSection] = [
        SettingSection(title: "일반", items: [
            // SettingItem(title: "재생 설정", icon: "play.circle", action: .playback),
            SettingItem(title: "태그 관리", icon: "tag", action: .tag)
        ]),
        SettingSection(title: "언어", items: [
            SettingItem(title: "언어 재설정", icon: "person.fill.checkmark.and.xmark", action: .language)
        ]),
        SettingSection(title: "기타", items: [
            SettingItem(title: "Intro재생(시연용)", icon: "info.circle", action: .intro),
            SettingItem(title: "앱 정보", icon: "info.circle", action: .about)
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
        view.backgroundColor = .systemBackground
        configureTableView()
    }

    /// 테이블 뷰 초기 설정 및 레이아웃 구성
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
    }
}

// MARK: - UITableViewDataSource

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings[section].items.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        settings[section].title
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = settings[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.image = UIImage(systemName: item.icon)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        let action = settings[indexPath.section].items[indexPath.row].action

        switch action {
        case .playback:
            print("재생 설정으로 이동")
        case .tag:
            let tagViewController = TagViewController()
            navigationController?.pushViewController(tagViewController, animated: true)
        case .language:
            showLanguageResetAlert()
        case .intro:
            let introPageViewController = IntroPageViewController()
            navigationController?.pushViewController(introPageViewController, animated: true)
        case .about:
            let alert = UIAlertController(
                title: "Team 2 : Mainboard",
                message: "김태윤, 김대현, 김찬영, 천용휘, 여승위",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - 언어 재설정 Alert

extension SettingViewController {

    /// 언어 재설정 안내 Alert 표시
    private func showLanguageResetAlert() {
        let alert = UIAlertController(
            title: "언어 재설정",
            message: "기존 언어 설정과 누적된 학습 데이터가 초기화됩니다.\n진행하시겠습니까?",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "재설정", style: .destructive) { [weak self] _ in
            self?.performLanguageReset()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    /// 언어 재설정 실행 및 IntroPage로 전환
    private func performLanguageReset() {
        WeightStore.shared.reset()
        UserDefaults.standard.set(false, forKey: IntroModel.introSeenKey)

        let introPageViewController = IntroPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        introPageViewController.showOnlyLastPage()
        introPageViewController.modalPresentationStyle = .fullScreen
        introPageViewController.modalTransitionStyle = .crossDissolve

        present(introPageViewController, animated: true)
    }
}

// MARK: - 미리보기
#Preview("SettingViewController") {
    UINavigationController(rootViewController: SettingViewController())
}
