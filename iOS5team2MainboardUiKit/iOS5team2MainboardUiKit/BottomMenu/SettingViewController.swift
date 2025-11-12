//
//  SettingViewController.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/12/25.
//

import UIKit
import SwiftUI // Preview용

struct SettingSection {
    let title: String
    let items: [SettingItem]
}

struct SettingItem {
    let title: String
    let icon: String
    let action: SettingAction
}

enum SettingAction {
    case language, playback, tag, about
}

final class SettingViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let settings: [SettingSection] = [
        SettingSection(title: "일반", items: [
            SettingItem(title: "재생 설정", icon: "play.circle", action: .playback),
            SettingItem(title: "태그 관리", icon: "tag", action: .tag)
        ]),
        SettingSection(title: "언어", items: [
            SettingItem(title: "언어 재설정", icon: "person.fill.checkmark.and.xmark", action: .language)
        ]),
        SettingSection(title: "기타", items: [
            SettingItem(title: "앱 정보", icon: "info.circle", action: .about)
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
        view.backgroundColor = .systemBackground
        configureTableView()
    }

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

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = settings[indexPath.section].items[indexPath.row].action

        switch action {
        case .playback:
            print("재생 설정으로 이동")
        case .tag:
            print("태그 설정으로 이동")
        case .language:
            print("언어 재설정으로 이동")
        case .about:
            let alert = UIAlertController(title: "Team 2 : Mainboard",
                                          message: "김태윤, 김대현, 김찬영, 천용휘, 여승위",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}

// Preview용
#Preview("SettingViewController") {
    UINavigationController(rootViewController: SettingViewController())
}
