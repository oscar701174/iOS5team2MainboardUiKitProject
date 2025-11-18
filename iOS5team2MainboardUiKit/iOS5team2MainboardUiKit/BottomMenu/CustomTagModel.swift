//
//  CustomTagModel.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/18/25.
//

import UIKit

// MARK: - 태그 모델 정의

/// # CustomIconCategory
/// 사용자 정의 태그(아이콘·색상·이름)를 저장하기 위한 데이터 모델입니다.
///
/// # Features
/// - UserDefaults에 저장 가능하도록 `Codable` 채택
/// - 태그 식별을 위한 고유 UUID 포함
/// - SF Symbol 이름과 색상(hex) 저장 가능
/// - 색상 변환(UIColor ↔︎ hex string) 지원
///
/// # Fields
/// - id: 고유 식별자
/// - name: 태그 이름(예: "액션", "코미디")
/// - iconName: SF Symbol 이름
/// - colorHex: hex 문자열 형태로 저장된 색상값
/// - isCustom: 커스텀 태그 여부(true 고정)
struct CustomIconCategory: Codable, Hashable {
    let id: UUID
    let name: String
    let iconName: String
    let colorHex: String
    let isCustom: Bool

    /// 저장된 Hex 문자열을 UIColor로 변환한 값
    var color: UIColor {
        UIColor(hex: colorHex) ?? .systemBlue
    }

    /// 새로운 사용자 태그 생성 시 사용하는 초기화 함수
    init(name: String, iconName: String, color: UIColor, isCustom: Bool) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = color.toHexString()
        self.isCustom = isCustom
    }
}

// MARK: - 사용자 태그 저장소

/// # CustomTagStore
/// 사용자 정의 태그를 UserDefaults에 저장·로드·삭제하는 싱글톤 저장소.
///
/// # Features
/// - JSON 인코딩/디코딩 기반 저장
/// - 태그 추가, 삭제, 전체 리셋 기능 제공
/// - MainView 및 TagViewController에서 공통적으로 사용됨
///
/// # Storage Key
/// - 내부적으로 `"CustomIconCategories"` 키를 사용하여 UserDefaults에 저장됩니다.
final class CustomTagStore {

    /// 싱글톤 인스턴스
    static let shared = CustomTagStore()

    /// UserDefaults에 저장할 키 값
    private let key = "CustomIconCategories"

    private init() {}

    // MARK: 저장

    /// 사용자 태그 전체 배열을 UserDefaults에 저장합니다.
    func save(_ categories: [CustomIconCategory]) {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: 불러오기

    /// 저장된 사용자 태그 목록을 UserDefaults에서 불러옵니다.
    ///
    /// 실패 시 빈 배열을 반환합니다.
    func load() -> [CustomIconCategory] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let categories = try? JSONDecoder().decode([CustomIconCategory].self, from: data) else {
            return []
        }
        return categories
    }

    // MARK: 추가

    /// 새로운 사용자 태그를 저장 목록에 추가합니다.
    func add(_ category: CustomIconCategory) {
        var current = load()
        current.append(category)
        save(current)
    }

    // MARK: 삭제

    /// 특정 태그를 id 기준으로 삭제합니다.
    func delete(_ category: CustomIconCategory) {
        var current = load()
        current.removeAll { $0.id == category.id }
        save(current)
    }

    // MARK: 초기화

    /// 저장된 사용자 태그를 모두 삭제합니다.
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - UIColor <-> Hex 변환 확장

/// # UIColor Extension
/// UIColor ↔︎ HEX 문자열 상호 변환을 지원하는 유틸리티입니다.
///
/// # Use Cases
/// - 사용자 선택 색상을 저장(UserDefaults)해야 할 때
/// - 저장된 hex 문자열을 UI 색상으로 복원해야 할 때
extension UIColor {

    /// hex 문자열("#RRGGBB")을 UIColor로 변환하는 초기화 함수
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb >> 16) & 0xff) / 255
        let g = CGFloat((rgb >> 8) & 0xff) / 255
        let b = CGFloat(rgb & 0xff) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    /// UIColor를 "#RRGGBB" 형태의 hex 문자열로 변환합니다.
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: nil)

        let rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format: "#%06x", rgb)
    }
}
