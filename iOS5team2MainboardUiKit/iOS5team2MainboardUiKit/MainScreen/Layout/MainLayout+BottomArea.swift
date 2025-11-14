//
//  MainLayout+BottomArea.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit

extension MainLayout {

    func setBottomMenu() {
        let bottomButtons: [UIButton] = [tagButton, clipButton, bottomSearchButton, settingButton]
        let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

        bottomButtonStackView.axis = .horizontal
        bottomButtonStackView.distribution = .fillEqually
        bottomButtonStackView.alignment = .center

        bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bottomBarView.isUserInteractionEnabled = false

        clipButton.setImage(UIImage(systemName: "paperclip",
                                    withConfiguration: cfg), for: .normal)
        tagButton.setImage(UIImage(systemName: "tag",
                                   withConfiguration: cfg), for: .normal)
        bottomSearchButton.setImage(UIImage(systemName: "magnifyingglass",
                                            withConfiguration: cfg), for: .normal)
        settingButton.setImage(UIImage(systemName: "gearshape",
                                       withConfiguration: cfg), for: .normal)

        bottomButtons.forEach { btn in
            btn.tintColor = AppColor.menuIcon
            btn.translatesAutoresizingMaskIntoConstraints = false
            bottomButtonStackView.addArrangedSubview(btn)
        }

        addSubview(bottomBarView)
        addSubview(bottomButtonStackView)

        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        bottomButtonStackView.isLayoutMarginsRelativeArrangement = true

        bottomMenuDefaultConstrains = [
            bottomBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 80),

            bottomButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 40)
        ]

        bottomMenuIPadLandscapeConstraints = [
            bottomBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 60),

            bottomButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 40)
        ]
    }

    func setSeachBar() {
        searchBar.placeholder = "검색"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.showsBookmarkButton = true
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.isHidden = true

        keyboardLayoutGuide.followsUndockedKeyboard = true

        searchBar.setImage(
            UIImage(systemName: "xmark")?.withTintColor(.gray, renderingMode: .alwaysOriginal),
            for: .bookmark,
            state: .normal
        )
        addSubview(searchBar)

        bottomToBottomMenu = searchBar.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor)
        bottomToBottomMenu.isActive = true
        bottomToBottomMenu.priority = .defaultHigh

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            searchBar.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
