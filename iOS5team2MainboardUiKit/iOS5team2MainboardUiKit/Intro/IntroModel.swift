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
    }

    static let introSeenKey = "hasSeenIntro"
// 인트로 각 페이지에 들어갈 아이콘, 제목, 문구
    static let pages: [IntPage] = [
        .init(icon: "swift",
              title: "페이지1",
              description: "테스트1",
              backgroundColor: .systemMint),
        .init(icon: "star",
              title: "페이지2",
              description: "테스트2",
              backgroundColor: .systemYellow),
        .init(icon: "lock",
              title: "페이지3",
              description: "테스트3",
              backgroundColor: .systemTeal),
        .init(icon: "bolt",
              title: "페이지4",
              description: "테스트4",
              backgroundColor: .systemIndigo)
    ]
// 취향 선택에 사용할 언어목록
    static let languages: ["Swift", "Kotlin", "Python", "JavaScript", "C++",
                           "테스트", "안녕하세요", "반갑습니다"]
}
