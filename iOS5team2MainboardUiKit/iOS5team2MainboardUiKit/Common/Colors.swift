//
//  Colors.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/7/25.
//

import UIKit

enum AppColor {
    static let primary: UIColor = .dynamic( // 버튼류 색상
        light: .rgb(0, 122, 255),
        dark: .rgb(51, 153, 242)
    )

    static let background: UIColor = .dynamic( // 백그라운드 색상
        light: .rgb(255, 255, 255),
        dark: .rgb(18, 18, 18)
    )

    static let textPrimary: UIColor = .dynamic( // 텍스트 색상
        light: .rgb(0, 0, 0),
        dark: .rgb(255, 255, 255)
    )
    
    static let menuIcon: UIColor = .dynamic( // 메뉴 아이콘 섹상
        light: .rgb(79, 194, 186),
        dark: .rgb(79, 194, 186)
    )
}

private extension UIColor {
    static func rgb(_ r: Int, _ g: Int, _ b: Int, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: alpha
        )
    }

    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }
}
