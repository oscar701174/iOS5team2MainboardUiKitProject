//
//  MainLayout+Layout.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import DropDown

extension MainLayout {

    /// # Overview
    /// iPad 환경 및 화면 방향(가로/세로)에 따라 레이아웃 제약을 업데이트합니다.
    ///
    /// # Discussion
    /// - iPad 가로 방향(landscape)일 때는 전용 제약(IPadLandscapeConstraints)을 활성화합니다.
    /// - 그 외(iPhone, iPad 세로)는 기본 제약(DefaultConstraints)을 활성화합니다.
    ///
    /// 이 메서드는 다음 상황에서 호출됩니다:
    /// - 회전 이벤트
    /// - `traitCollectionDidChange`
    /// - `viewDidLayoutSubviews` 등 레이아웃 업데이트 시점  
    ///
    /// - Parameters:
    ///   - trait: 현재 기기의 TraitCollection (iPad 여부, size class 등)
    ///   - containerSize: 외부에서 전달한 컨테이너 크기. 전달되지 않으면 `bounds.size`를 사용
    ///
    /// - Note:
    ///   iPad 가로 모드에서만 레이아웃이 크게 변하도록 설계되었습니다.
    func updateForIpad(for trait: UITraitCollection, containerSize: CGSize? = nil) {

        let size = containerSize ?? bounds.size

        let isIpadLandscape =
            trait.userInterfaceIdiom == .pad &&
            size.width > size.height

        if isIpadLandscape {
            // iPad 가로 전용 레이아웃 활성화
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
            // 기본 레이아웃 활성화 (iPhone or iPad 세로)
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

    /// # Overview
    /// 다크모드/라이트모드 등 TraitCollection 변화에 따라 DropDown의 색상을 갱신합니다.
    ///
    /// # Discussion
    /// 앱 전체 테마가 변할 때 드롭다운이 자연스럽게 어울리도록
    /// 배경색과 텍스트 색상을 TraitCollection 기준으로 새로 설정합니다.
    ///
    /// - Parameters:
    ///   - trait: 현재 traitCollection (appearance, 색상 모드 등)
    func updateDropdownColors(for trait: UITraitCollection) {

        let backgroundColor = AppColor.background.resolvedColor(with: trait)
        let textColor = UIColor.main

        langauageDropDown.backgroundColor = backgroundColor
        langauageDropDown.textColor = textColor

        speedDropDown.backgroundColor = backgroundColor
        speedDropDown.textColor = textColor
    }
}
