//
//  IntroModel.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

struct IntroModel {
    struct IntPage {
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

    static let pages: [IntPage] = [
        .init(
            icon: "swift",
            title: "페이지1",
            description: "테스트1 학교종이 땡땡땡",
            backgroundColor: .systemMint,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        ),
        .init(
            icon: "star",
            title: "페이지2",
            description: "테스트2 어서모이자",
            backgroundColor: .systemYellow,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .black
        ),
        .init(
            icon: "lock",
            title: "페이지3",
            description: "테스트3 선생님이 우리를",
            backgroundColor: .systemTeal,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        ),
        .init(
            icon: "bolt",
            title: "페이지4",
            description: "테스트4 기다리신다",
            backgroundColor: .systemIndigo,
//            titleFont: .systemFont(ofSize: 28, weight: .heavy),
//            descriptionFont: .systemFont(ofSize: 16, weight: .medium),
            fontColor: .white
        )
    ]

    static let languages: [String] = [
        "Angular", "C", "Django", "Docker", "Java",
        "JavaScript", "Kotlin", "Kubernetes", "NoSQL", "PHP",
        "Python", "React", "Spring", "Swift", "Vuejs"
    ]

    static let introSeenKey = "hasSeenIntro"
}
