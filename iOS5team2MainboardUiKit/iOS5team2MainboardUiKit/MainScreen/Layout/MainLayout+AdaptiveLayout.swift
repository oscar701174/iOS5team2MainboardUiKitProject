//
//  MainLayout+Layout.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import DropDown

extension MainLayout {

    // MARK: - iPad Layout Handling

    /// # Overview
    /// iPad 환경 및 화면 방향(가로/세로)에 따라 레이아웃 제약을 전환합니다.
    ///
    /// # Discussion
    /// 이 메서드는 iPad의 **가로 모드일 때만 레이아웃을 크게 변경**하도록 설계되었으며,
    /// 가로 모드에서는 폭이 넓어지는 점을 고려해 전용 제약(IPadLandscapeConstraints)을 사용합니다.
    ///
    /// 다음 상황에서 자동으로 호출됩니다:
    /// - 기기 회전(`viewWillTransition`)
    /// - traitCollection 변경
    /// - `viewDidLayoutSubviews`를 통한 레이아웃 업데이트
    ///
    /// iPhone이나 iPad 세로 모드에서는 기본 제약(DefaultConstraints)을 적용하여
    /// 일반적인 단일 열 UI 구조를 유지합니다.
    ///
    /// - Parameters:
    ///   - trait: 현재 UI 환경(iPad 여부, size class 등)
    ///   - containerSize: 외부에서 전달한 레이아웃 기준 크기 (없으면 `bounds.size` 사용)
    func updateForIpad(for trait: UITraitCollection, containerSize: CGSize? = nil) {

        let size = containerSize ?? bounds.size

        /// iPad + 가로 화면 조건 정의
        let isIpadLandscape =
            trait.userInterfaceIdiom == .pad &&
            size.width > size.height

        if isIpadLandscape {
            // iPad 가로 전용 레이아웃 활성화 (넓은 화면 기준)
            NSLayoutConstraint.deactivate(headerDefaultConstriants)
            NSLayoutConstraint.deactivate(topVideoDefaultConstraints)
            NSLayoutConstraint.deactivate(progressSliderDefaultConstraints)
            NSLayoutConstraint.deactivate(videoButtonDefaultConstraints)
            NSLayoutConstraint.deactivate(videoCollectionDefaultConstraints)
            NSLayoutConstraint.deactivate(bottomMenuDefaultConstrains)

            NSLayoutConstraint.activate(headerIPadLandscapeConstriants)
            NSLayoutConstraint.activate(topVideoIPadLandscapeConstraints)
            NSLayoutConstraint.activate(progressSliderIPadLandscapeConstraints)
            NSLayoutConstraint.activate(videoButtonIPadLandscapeConstraints)
            NSLayoutConstraint.activate(videoCollectionIPadLandscapeConstraints)
            NSLayoutConstraint.activate(bottomMenuIPadLandscapeConstraints)

        } else {
            // iPhone 또는 iPad 세로(기본 레이아웃)
            NSLayoutConstraint.deactivate(headerIPadLandscapeConstriants)
            NSLayoutConstraint.deactivate(topVideoIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(progressSliderIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(videoButtonIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(videoCollectionIPadLandscapeConstraints)
            NSLayoutConstraint.deactivate(bottomMenuIPadLandscapeConstraints)

            NSLayoutConstraint.activate(headerDefaultConstriants)
            NSLayoutConstraint.activate(topVideoDefaultConstraints)
            NSLayoutConstraint.activate(progressSliderDefaultConstraints)
            NSLayoutConstraint.activate(videoButtonDefaultConstraints)
            NSLayoutConstraint.activate(videoCollectionDefaultConstraints)
            NSLayoutConstraint.activate(bottomMenuDefaultConstrains)
        }

        layoutIfNeeded()
    }

    // MARK: - DropDown Appearance Update

    /// # Overview
    /// 다크모드/라이트모드 등 appearance 변경에 따라 DropDown의 색상을 갱신합니다.
    ///
    /// # Discussion
    /// DropDown은 UIKit의 자동 색상 대응을 받지 않기 때문에
    /// traitCollection 변경 시 직접 색상을 업데이트해야 합니다.
    ///
    /// 이를 통해:
    /// - 다크모드에서는 어두운 배경 + 밝은 텍스트
    /// - 라이트모드에서는 밝은 배경 + 기본 텍스트
    ///
    /// 로 자연스럽게 UI가 이어지도록 만듭니다.
    ///
    /// - Parameters:
    ///   - trait: 현재 UI trait (색상 모드, 다크/라이트 등)
    func updateDropdownColors(for trait: UITraitCollection) {

        /// AppColor.background: 프로젝트 전체에서 사용되는 공통 배경색
        let backgroundColor = AppColor.background.resolvedColor(with: trait)
        let textColor = UIColor.main

        langauageDropDown.backgroundColor = backgroundColor
        langauageDropDown.textColor = textColor

        speedDropDown.backgroundColor = backgroundColor
        speedDropDown.textColor = textColor
    }
}
