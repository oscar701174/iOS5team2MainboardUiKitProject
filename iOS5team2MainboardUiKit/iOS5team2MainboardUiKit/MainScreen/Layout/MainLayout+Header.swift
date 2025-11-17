//
//  MainLayout+Header.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import DropDown

extension MainLayout {

    /// # Overview
    /// 화면 상단 헤더 영역을 구성합니다.
    ///
    /// # Discussion
    /// 헤더는 크게 두 요소로 이루어져 있습니다:
    /// - 언어 선택 버튼 (`languageButton`)
    /// - 검색 버튼 (`searchButton`)
    ///
    /// iPhone / iPad 세로 방향에서는 기본 제약을 적용하고,  
    /// iPad 가로 방향에서는 버튼 크기와 위치가 달라지도록  
    /// 별도의 레이아웃 제약을 준비합니다.
    ///
    /// 헤더는 앱의 탐색 흐름에서 가장 먼저 사용자가 보게 되는 영역이며,  
    /// 언어 변경과 검색 기능 접근의 진입점 역할을 합니다.
    func setHeader() {
        addSubview(languageButton)
        addSubview(searchButton)

        languageButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        // 기본(iPhone, iPad 세로) 제약
        headerDefaultConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            languageButton.widthAnchor.constraint(equalTo: widthAnchor, constant: 30),

            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 62),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]

        // iPad 가로(landscape) 전용 헤더 제약
        headerIPadLandscapeConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            languageButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            languageButton.heightAnchor.constraint(equalToConstant: 90),

            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]

        // 초기 타이틀 및 아이콘 설정 - "전체" 기본 선택
        languageButton.setTitle("전체", for: .normal)
        languageButton.setImage(
            UIImage(named: "IconBlack")?
                .resized(to: .init(width: 34, height: 34))
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        languageButton.tintColor = AppColor.menuIcon

        // 정렬 및 텍스트 스타일
        languageButton.contentHorizontalAlignment = .leading
        languageButton.titleEdgeInsets.left = 5
        languageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        languageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        languageButton.setTitleColor(.main, for: .normal)
        languageButton.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)

        // 검색 버튼 이미지 설정
        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        searchButton.setImage(img, for: .normal)
        searchButton.tintColor = .main

        // 버튼 기본 설정
        languageButton.showsMenuAsPrimaryAction = false
        languageButton.clipsToBounds = true
    }

    /// # Overview
    /// 언어 선택 드롭다운 메뉴를 설정합니다.
    ///
    /// # Discussion
    /// `DropDown` 라이브러리를 사용하여  
    /// 언어 버튼을 눌렀을 때 나타나는 리스트 UI를 구성합니다.
    ///
    /// - 메뉴 항목은 `CategoryRepository.allCategories` 기준  
    /// - 선택 시:  
    ///   1) 버튼 타이틀 변경  
    ///   2) 아이콘 변경  
    ///   3) `onLanguageSelected` 콜백 실행  
    ///
    /// iPhone / iPad 세로 / iPad 가로 방향에 따라  
    /// 드롭다운 너비와 표시 위치(bottomOffset)를 다르게 계산합니다.
    func configureLanguageMenu() {

        // "전체" + 기존 항목
        let dataSource = ["전체"] + itemList

        langauageDropDown.dismissMode = .automatic
        langauageDropDown.dataSource = dataSource
        langauageDropDown.anchorView = languageButton
        langauageDropDown.textFont = .boldSystemFont(ofSize: UIFont.labelFontSize)
        langauageDropDown.direction = .bottom

        // 메뉴가 표시되기 직전, 레이아웃에 맞춰 동적 크기 조정
        langauageDropDown.willShowAction = { [weak self] in
            guard let self, self.languageButton.window != nil else { return }
            self.languageButton.layoutIfNeeded()

            let isIPadLandscape =
                self.traitCollection.userInterfaceIdiom == .pad &&
                self.bounds.width > self.bounds.height

            if isIPadLandscape {
                // iPad 가로 → 더 넓은 DropDown
                self.langauageDropDown.width = self.languageButton.bounds.width * 0.6
                self.langauageDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.languageButton.bounds.height - 20
                )

            } else {
                // 기본 너비: 버튼의 약 30% 만큼
                let contentWidth = self.languageButton.bounds.width * 0.3
                self.langauageDropDown.width = min(contentWidth, self.bounds.width)

                self.langauageDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.languageButton.bounds.height + 3
                )
            }
        }

        // 항목 선택 시 버튼 값/아이콘 업데이트
        langauageDropDown.selectionAction = { [weak self] (index, item) in
            guard let self else { return }

            // index 0 = "전체"
            if index == 0 {
                self.languageButton.setTitle("전체", for: .normal)
                self.languageButton.setImage(
                    UIImage(named: "IconBlack")?
                        .resized(to: .init(width: 34, height: 34))
                        .withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                self.languageButton.tintColor = AppColor.menuIcon
                self.onLanguageSelected?("전체")
                return
            }

            // 실제 카테고리 인덱스는 -1 보정
            let actualIndex = index - 1
            let name = self.itemList[actualIndex]

            self.languageButton.setTitle(item, for: .normal)
            self.onLanguageSelected?(item)

            if let category = CategoryRepository.allCategories.first(where: { $0.name == name }) {
                let icon = UIImage(named: category.iconName)?
                    .resized(to: .init(width: 34, height: 34))
                self.languageButton.setImage(icon, for: .normal)
            } else {
                self.languageButton.setImage(nil, for: .normal)
            }
        }

        // 현재 테마(dark/light)에 맞게 DropDown 스타일 적용
        updateDropdownColors(for: languageButton.traitCollection)

        langauageDropDown.reloadAllComponents()
    }
}

