//
//  IntroModel.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

/// # Overview
/// 앱 인트로 화면에서 사용할 페이지 구성 정보를 담는 모델입니다.
///
/// # Discussion
/// 각 페이지에는 아이콘 이미지, 타이틀, 설명 텍스트, 배경색, 폰트 스타일, 폰트 색상 등이 포함됩니다.
/// `UIPageViewController`를 사용하는 `IntroPageViewController`에서 이 모델을 기반으로 화면을 구성합니다.
///
/// - 각 인트로 페이지는 `IntroPage` 타입으로 정의됩니다.
/// - `IntroModel.pages`에 전체 인트로 페이지 정보 배열이 저장되어 있으며,
///   이 배열은 인트로 화면 구성에 직접 사용됩니다.
///
/// ## 주요 기능
/// - 정적 데이터 형태의 인트로 페이지 설정
/// - 사용자 인트로 경험 여부 저장 키 관리 (`UserDefaults`)
struct IntroModel {

    /// # IntroPage
    /// 인트로에서 보여줄 각 단일 페이지를 정의하는 구조체입니다.
    struct IntroPage {
        let icon: String
        let title: String
        let description: String

        let backgroundColor: UIColor
        let titleFont: UIFont
        let descriptionFont: UIFont
        let fontColor: UIColor

        /// 인트로 페이지 생성자
        /// - Parameters:
        ///   - icon: 페이지에서 사용할 이미지 이름 (Assets 내 이미지)
        ///   - title: 제목 텍스트
        ///   - description: 설명 텍스트
        ///   - backgroundColor: 배경색 (기본값: systemBackground)
        ///   - titleFont: 제목 폰트 (기본값: 28pt Bold)
        ///   - descriptionFont: 설명 폰트 (기본값: 16pt Medium)
        ///   - fontColor: 텍스트 색상 (기본값: label)
        init(
            icon: String,
            title: String,
            description: String,
            backgroundColor: UIColor = .systemBackground,
            titleFont: UIFont = .systemFont(ofSize: 28, weight: .bold),
            descriptionFont: UIFont = .systemFont(ofSize: 16, weight: .medium),
            fontColor: UIColor = .label
        ) {
            self.icon = icon
            self.title = title
            self.description = description
            self.backgroundColor = backgroundColor
            self.titleFont = titleFont
            self.descriptionFont = descriptionFont
            self.fontColor = fontColor
        }
    }

    /// # pages
    /// 인트로 화면에 표시될 전체 페이지 목록입니다.
    ///
    /// 각 페이지는 고정된 설명/이미지를 포함하며 사용자의 앱 이해를 돕기 위해 구성됩니다.
    static let pages: [IntroPage] = [
        .init(
            icon: "Intro1",
            title: "미디어 파일을 담아보세요",
            description: "플레이 할 미디어 파일을 카테고리별로 담아 필요할 때 언제든 꺼내 볼 수 있는 어플입니다. 플레이어를 통해 나의 역량을 늘려보세요",
            backgroundColor: .white,
            fontColor: .black
        ),
        .init(
            icon: "Intro2",
            title: "나만의 영상을 저장해 보세요",
            description: "필요한 영상만 골라 나만의 저장소에 담아보세요. 사이트를 찾아 헤매지 않고 필요한 자료를 언제든 플레이 할 수 있습니다",
            backgroundColor: .white,
            fontColor: .black
        ),
        .init(
            icon: "Intro3",
            title: "클립하여 필요한 구간만 쏙!",
            description: "나의 미디어 플레이어를 필요한 구간에 간편하게 클립하여 나만의 영상을 남기세요. 반복하여 보며 학습을 이어갈 수 있습니다",
            backgroundColor: .white,
            fontColor: .black
        ),
        .init(
            icon: "Intro4",
            title: "나만의 플레이어 저장소",
            description: "이제 나만의 플레이어를 즐겨보세요.\n당신을 새로운 세계로 안내합니다",
            backgroundColor: .white,
            fontColor: .black
        )
    ]

    /// # introSeenKey
    /// 인트로를 본 적 있는지를 저장하는 UserDefaults 키입니다.
    ///
    /// - true면 인트로 생략
    /// - false면 인트로 페이지 표시
    static let introSeenKey = "hasSeenIntro"
}
