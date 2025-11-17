//
//  Colors.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/7/25.
//

import UIKit

/// 앱 전반에서 사용하는 색상을 정의한 컬렉션입니다.
/// Light/Dark 모드에 대응하는 동적 색상을 제공합니다.
enum AppColor {

    /// 주요 인터랙션 요소에 사용되는 색상입니다.
    static let primary: UIColor = .dynamic(
        light: .rgb(0, 122, 255),
        dark: .rgb(51, 153, 242)
    )

    /// 화면 배경에 사용되는 기본 색상입니다.
    static let background: UIColor = .dynamic(
        light: .rgb(255, 255, 255),
        dark: .rgb(18, 18, 18)
    )

    /// 일반 텍스트에 사용되는 색상입니다.
    static let textPrimary: UIColor = .dynamic(
        light: .rgb(0, 0, 0),
        dark: .rgb(255, 255, 255)
    )

    /// 메뉴 아이콘 등에 사용되는 보조 색상입니다.
    static let menuIcon: UIColor = .dynamic(
        light: .rgb(79, 194, 186),
        dark: .rgb(79, 194, 186)
    )
}

private extension UIColor {

    /// # Overview
    /// RGB 정수 값을 기반으로 UIColor를 생성합니다.
    ///
    /// # Parameters
    /// - red: 0~255 범위의 정수 값
    /// - green: 0~255 범위의 정수 값
    /// - blue: 0~255 범위의 정수 값
    /// - alpha: 투명도 (기본값 1.0)
    ///
    /// # Returns
    /// 지정된 RGB 값의 UIColor
    static func rgb(_ red: Int, _ green: Int, _ blue: Int, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: alpha
        )
    }

    /// # Overview
    /// 라이트/다크 모드에 따라 서로 다른 색상을 제공하는 Dynamic Color를 생성합니다.
    ///
    /// # Parameters
    /// - light: 라이트 모드에서 사용할 색상
    /// - dark: 다크 모드에서 사용할 색상
    ///
    /// # Returns
    /// 환경에 따라 색상이 변경되는 UIColor
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }
}
