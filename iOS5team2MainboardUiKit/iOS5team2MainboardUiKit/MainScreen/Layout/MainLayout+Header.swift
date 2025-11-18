//
//  MainLayout+Header.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import DropDown

extension MainLayout {
    
    // MARK: - Header Layout
    
    /// # Overview
    /// 화면 상단 헤더 영역(언어 선택 버튼 + 검색 버튼)을 구성합니다.
    ///
    /// # Discussion
    /// 헤더는 앱에서 가장 먼저 보이는 UI 영역이며,
    /// **언어 변경 기능과 검색 기능의 진입점** 역할을 합니다.
    ///
    /// 레이아웃은 다음 기준으로 분리되어 있습니다:
    /// - iPhone & iPad 세로 방향: 기본 헤더 제약(`headerDefaultConstraints`)
    /// - iPad 가로 방향: 보다 넓고 여유 있는 구성(`headerIPadLandscapeConstraints`)
    ///
    /// 언어 버튼은 “아이콘 + 텍스트” 형태로 구성되며
    /// 왼쪽 정렬(leading alignment)로 설정해 iOS의 기본 메뉴 버튼 스타일과 일관성을 갖습니다.
    func setHeader() {
        addSubview(languageButton)
        addSubview(searchButton)
        
        languageButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: 기본(iPhone, iPad 세로) 제약
        headerDefaultConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            
            /// widthAnchor = widthAnchor + 30
            /// → 실제 width 고정이 아니라, intrinsicContentSize 사용 시
            ///   레이아웃 경고를 피하기 위한 "여유 폭" 확보용 제약입니다.
            languageButton.widthAnchor.constraint(equalTo: widthAnchor, constant: 30),
            
            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 62),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]
        
        // MARK: iPad 가로 전용 제약
        /// iPad 가로에서는 화면 폭이 커지기 때문에
        /// 언어 버튼의 높이/폭을 더 넓게 사용합니다.
        headerIPadLandscapeConstriants = [
            languageButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            languageButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            languageButton.heightAnchor.constraint(equalToConstant: 90),
            
            searchButton.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]
        
        // MARK: 언어 버튼 기본 스타일
        languageButton.setTitle("전체", for: .normal)
        languageButton.setImage(
            UIImage(named: "IconBlack")?
                .resized(to: .init(width: 34, height: 34))
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        languageButton.tintColor = AppColor.menuIcon
        
        // 텍스트/아이콘 정렬 설정
        languageButton.contentHorizontalAlignment = .leading
        languageButton.titleEdgeInsets.left = 5
        languageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        languageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        languageButton.setTitleColor(.main, for: .normal)
        languageButton.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        
        // MARK: 검색 버튼 스타일
        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        searchButton.setImage(
            UIImage(systemName: "magnifyingglass", withConfiguration: cfg),
            for: .normal
        )
        searchButton.tintColor = .main
        
        languageButton.showsMenuAsPrimaryAction = false
        languageButton.clipsToBounds = true
    }
    
    func updateLanguageMenuItems() {
            let defaultCategories = CategoryRepository.allCategories.map(\.name)
            let customCategories = CustomTagStore.shared.load().map(\.name)
            itemList = defaultCategories
            langauageDropDown.dataSource = ["전체"] + defaultCategories + customCategories
            langauageDropDown.reloadAllComponents()
        }
    
    // MARK: - Language DropDown
    
    /// # Overview
    /// 언어 선택 드롭다운 메뉴를 설정합니다.
    ///
    /// # Discussion
    /// `DropDown` 라이브러리를 사용하여
    /// 언어 버튼을 눌렀을 때 나타나는 언어 목록 리스트를 구성합니다.
    ///
    /// 메뉴 동작 구조:
    /// 1) "전체" + 등록된 카테고리 목록을 데이터로 사용
    /// 2) 언어 선택 시 버튼의 텍스트/아이콘을 해당 언어로 변경
    /// 3) 선택된 언어는 `onLanguageSelected` 콜백을 통해 MainViewController로 전달
    ///
    /// 또한 iPhone / iPad 세로 / iPad 가로에 따라
    /// DropDown의 width 및 bottomOffset이 다르게 계산됩니다.
    /// (버튼의 크기가 다르기 때문에 위치 보정 필요)
    func configureLanguageMenu() {
        
        // 사용자 태그 로딩
        updateLanguageMenuItems()
        langauageDropDown.dismissMode = .automatic
        langauageDropDown.anchorView = languageButton
        langauageDropDown.textFont = .boldSystemFont(ofSize: UIFont.labelFontSize)
        langauageDropDown.direction = .bottom
        
        // MARK: DropDown 표시 직전 레이아웃 조정
        langauageDropDown.willShowAction = { [weak self] in
            guard let self, self.languageButton.window != nil else { return }
            self.languageButton.layoutIfNeeded()
            
            let isIPadLandscape =
            self.traitCollection.userInterfaceIdiom == .pad &&
            self.bounds.width > self.bounds.height
            
            if isIPadLandscape {
                self.langauageDropDown.width = self.languageButton.bounds.width * 0.6
                self.langauageDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.languageButton.bounds.height - 20
                )
            } else {
                let contentWidth = self.languageButton.bounds.width * 0.3
                self.langauageDropDown.width = min(contentWidth, self.bounds.width)
                self.langauageDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.languageButton.bounds.height + 3
                )
            }
        }
        
        // MARK: DropDown 선택 동작
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

            // 실제 카테고리 index는 -1 보정
            let actualIndex = index - 1
            let allDefaults = CategoryRepository.allCategories.map(\.name)
            let customTags = CustomTagStore.shared.load()

            self.languageButton.setTitle(item, for: .normal)
            self.onLanguageSelected?(item)

            if actualIndex < allDefaults.count {
                // 기본 카테고리 → 아이콘만 설정
                let categoryName = allDefaults[actualIndex]
                if let category = CategoryRepository.allCategories.first(where: { $0.name == categoryName }) {
                    let icon = UIImage(named: category.iconName)?
                        .resized(to: .init(width: 34, height: 34))
                    self.languageButton.setImage(icon, for: .normal)
                    self.languageButton.tintColor = AppColor.menuIcon
                }
            } else {
                // 사용자 태그 → SF Symbol + 색상
                let customIndex = actualIndex - allDefaults.count
                if customIndex < customTags.count {
                    let tag = customTags[customIndex]
                    let icon = UIImage(systemName: tag.iconName)?
                        .resized(to: .init(width: 34, height: 34))
                    self.languageButton.setImage(icon, for: .normal)
                    self.languageButton.tintColor = tag.color
                }
            }
            
            self.onLanguageSelected?(item)
        }
        
        updateDropdownColors(for: languageButton.traitCollection)
        langauageDropDown.reloadAllComponents()
    }
}
