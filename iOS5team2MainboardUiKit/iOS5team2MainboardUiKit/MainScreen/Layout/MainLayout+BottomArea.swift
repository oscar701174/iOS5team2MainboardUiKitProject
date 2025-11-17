//
//  MainLayout+BottomArea.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit

extension MainLayout {

    /// # Overview
    /// 화면 하단에 표시되는 메뉴바 영역을 구성합니다.
    ///
    /// # Discussion
    /// 하단 메뉴는 다음 4개의 주요 버튼으로 이루어져 있습니다:
    /// - 태그(Tag)
    /// - 클립(Clip)
    /// - 검색(Search)
    /// - 설정(Settings)
    ///
    /// 이 버튼들은 `UIStackView`를 이용해 가로로 동일한 크기로 분배되며,
    /// `bottomBarView`는 시각적인 배경 역할을 수행합니다.
    ///
    /// iPhone / iPad 세로에서는 기본 높이(80)를,
    /// iPad 가로(landscape)에서는 더 낮은 높이(60)를 적용하여
    /// 기기 특성에 맞는 UI 비율을 유지합니다.
    ///
    /// - Note:
    ///   `bottomBarView`는 입력을 받지 않으며
    ///   실제 인터랙션은 `bottomButtonStackView` 내부 버튼에서 수행됩니다.
    func setBottomMenu() {
        let bottomButtons: [UIButton] = [tagButton, clipButton, bottomSearchButton, settingButton]
        let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

        // StackView 기본 구성
        bottomButtonStackView.axis = .horizontal
        bottomButtonStackView.distribution = .fillEqually
        bottomButtonStackView.alignment = .center

        // 하단 배경 바는 단순한 시각적 영역
        bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bottomBarView.isUserInteractionEnabled = false

        // 각 버튼에 아이콘 적용
        clipButton.setImage(UIImage(systemName: "paperclip", withConfiguration: cfg), for: .normal)
        tagButton.setImage(UIImage(systemName: "tag", withConfiguration: cfg), for: .normal)
        bottomSearchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: cfg), for: .normal)
        settingButton.setImage(UIImage(systemName: "gearshape", withConfiguration: cfg), for: .normal)

        // 공통 버튼 스타일 지정
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

        // MARK: - 기본 레이아웃 (iPhone / iPad 세로)
        bottomMenuDefaultConstrains = [
            bottomBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 80),

            bottomButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 40)
        ]

        // MARK: - iPad 가로 전용 레이아웃
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
    /// 상단에서 내려오는 검색바(SearchBar)를 초기 설정합니다.
    ///
    /// # Discussion
    /// 검색바는 **검색 버튼을 누르면 나타나고**,
    /// **취소 버튼을 누르면 숨겨지는** 토글 방식의 UI입니다.
    ///
    /// `keyboardLayoutGuide`를 활용하여
    /// 키보드가 나타날 경우 검색바가 자동으로 위쪽으로 이동해
    /// 입력 UI가 가려지지 않도록 보호합니다.
    ///
    /// 설정 요소:
    /// - X 버튼(북마크 버튼 아이콘)을 커스텀 X 아이콘으로 변경
    /// - Cancel 버튼 활성화
    /// - 배경 제거(투명하게 표시)
    /// - 기본은 `isHidden = true` 로 숨겨둔 상태
    ///
    /// - Note:
    ///   `showsBookmarkButton = true`를 사용하여
    ///   검색어 지우기 버튼(X)을 직접 이미지로 지정합니다.
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

        // 키보드 이동 시 따라오게 설정
        keyboardLayoutGuide.followsUndockedKeyboard = true

        // 북마크(X) 버튼 이미지 지정
        searchBar.setImage(
            UIImage(systemName: "xmark")?
                .withTintColor(.gray, renderingMode: .alwaysOriginal),
            for: .bookmark,
            state: .normal
        )

        addSubview(searchBar)

        // SearchBar 기본 위치 제약
        bottomToBottomMenu = searchBar.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor)
        bottomToBottomMenu.isActive = true
        bottomToBottomMenu.priority = .defaultHigh

        // 좌/우 기본 제약 및 키보드 등장 시 최대 위치 조정
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            searchBar.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
