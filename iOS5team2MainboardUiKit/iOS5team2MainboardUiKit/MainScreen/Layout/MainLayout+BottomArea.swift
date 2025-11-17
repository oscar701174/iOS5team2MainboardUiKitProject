//
//  MainLayout+BottomArea.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit

extension MainLayout {

    /// # Overview
    /// 화면 하단에 표시되는 메뉴바(UIBar 영역)를 구성합니다.
    ///
    /// # Discussion
    /// 하단 메뉴는 ‘태그’, ‘클립’, ‘검색’, ‘설정’ 버튼으로 이루어진 네 개의 아이콘 버튼이며,
    /// 가로로 균등 분배된 `UIStackView`로 배치됩니다.
    ///
    /// 또한 iPhone / iPad 세로 방향과  
    /// iPad 가로(landscape) 방향에서 높이가 달라지도록  
    /// 두 종류의 제약 조건을 설정합니다.
    ///
    /// - Note:
    ///   `bottomBarView`는 시각적 배경 역할만 하고  
    ///   `bottomButtonStackView` 내부 버튼들이 실제로 사용자 입력을 받습니다.
    func setBottomMenu() {
        let bottomButtons: [UIButton] = [tagButton, clipButton, bottomSearchButton, settingButton]
        let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

        // StackView 설정
        bottomButtonStackView.axis = .horizontal
        bottomButtonStackView.distribution = .fillEqually
        bottomButtonStackView.alignment = .center

        // 하단 배경 바 설정
        bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bottomBarView.isUserInteractionEnabled = false

        // 아이콘 설정
        clipButton.setImage(UIImage(systemName: "paperclip", withConfiguration: cfg), for: .normal)
        tagButton.setImage(UIImage(systemName: "tag", withConfiguration: cfg), for: .normal)
        bottomSearchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: cfg), for: .normal)
        settingButton.setImage(UIImage(systemName: "gearshape", withConfiguration: cfg), for: .normal)

        // 버튼들 공통 설정
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

        // 기본 레이아웃(iPhone 및 iPad 세로)
        bottomMenuDefaultConstrains = [
            bottomBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 80),

            bottomButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 40)
        ]

        // iPad 가로 방향 전용 레이아웃
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

    /// # Overview
    /// 상단에서 내려오는 검색바(SearchBar)를 초기 설정하고
    /// 키보드와의 동적 제약을 구성합니다.
    ///
    /// # Discussion
    /// - 검색 버튼 탭 시 표시되고  
    /// - 검색 취소 시 숨겨지는  
    /// 토글 방식의 검색 UI입니다.
    ///
    /// `keyboardLayoutGuide`를 이용해  
    /// 키보드 등장 시 SearchBar가 가려지지 않도록 자동으로 이동하도록 구성합니다.
    ///
    /// - Note:
    ///   `showsBookmarkButton = true`는  
    ///   검색어 지우기(X 버튼)를 직접 지정하기 위함입니다.
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
            UIImage(systemName: "xmark")?
                .withTintColor(.gray, renderingMode: .alwaysOriginal),
            for: .bookmark,
            state: .normal
        )

        addSubview(searchBar)

        // SearchBar의 기본 위치 제약
        bottomToBottomMenu = searchBar.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor)
        bottomToBottomMenu.isActive = true
        bottomToBottomMenu.priority = .defaultHigh

        // 좌/우/키보드 위 최소 제약
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            searchBar.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
