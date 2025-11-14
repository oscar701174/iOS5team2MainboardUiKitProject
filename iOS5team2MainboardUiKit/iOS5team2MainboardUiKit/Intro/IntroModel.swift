//
//  IntroModel.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

struct IntroModel {
    struct IntroPage {
        let icon: String
        let title: String
        let description: String

        let backgroundColor: UIColor
        let titleFont: UIFont
        let descriptionFont: UIFont
        let fontColor: UIColor

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

    static let pages: [IntroPage] = [
        .init(
            icon: "swift",
            title: "미디어 파일을 담아보세요",
            description: "플레이 할 미디어 파일을 카테고리별로 담아 필요할떄 언제든 꺼내 볼 수 있는 어플입니다. 플레이어를 통해 나의 역량을 늘려보세요",
            backgroundColor: .systemMint,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        ),
        .init(
            icon: "star",
            title: "나만의 영상을 저장해 보세요",
            description: "필요한 영상만 골라 나만의 저장소에 담아보세요. 사이트를 찾아 헤매이지 않고 필요한 자료를 언제든 플레이 할 수 있습니다",
            backgroundColor: .systemYellow,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .black
        ),
        .init(
            icon: "lock",
            title: "클립하여 필요한 구간만 쏙!",
            description: "나의 미디어 플레이어를 필요한 구간에 간편하게 클립하여 나만의 영상을 남기세요. 반복하여 보며 학습을 이어갈 수 있습니다",
            backgroundColor: .systemTeal,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        ),
        .init(
            icon: "bolt",
            title: "나만의 플레이어 저장소",
            description: "",
            backgroundColor: .systemIndigo,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        )
    ]

//    static let languages: [String] = [
//        "Angular", "C", "Django", "Docker", "Java",
//        "JavaScript", "Kotlin", "Kubernetes", "NoSQL", "PHP",
//        "Python", "React", "Spring", "Swift", "Vuejs"
//    ]

    static let introSeenKey = "hasSeenIntro"
}
