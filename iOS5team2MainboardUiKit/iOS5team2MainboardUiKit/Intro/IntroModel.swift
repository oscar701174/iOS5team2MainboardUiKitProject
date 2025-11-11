//
//  IntroModel.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/11/25.
//

import UIKit

struct IntroModel {
    let icon: String
    let title: String
    let description: String
    let backgroundColor: UIColor

    static let pages: [IntroModel] = [
        .init(icon: "swift", title: "제목1", description: "테스트", backgroundColor: .systemMint),
        .init(icon: "star", title: "제목2", description: "테스트", backgroundColor: .systemYellow),
        .init(icon: "lock", title: "제목3", description: "테스트", backgroundColor: .systemTeal),
        .init(icon: "bolt", title: "제목4", description: "테스트", backgroundColor: .systemIndigo)
    ]
}
