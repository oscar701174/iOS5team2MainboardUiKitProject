//
//  Languages.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/13/25.
//

import UIKit

/// 카테고리를 나타내는 모델입니다.
/// 드롭다운, 필터링, 언어 선택 등에서 사용됩니다.
struct Category {
    /// UI에 표시될 카테고리 이름입니다.
    let name: String

    /// Asset Catalog에 등록된 아이콘 파일명입니다.
    let iconName: String
}

/// 카테고리 그룹을 표현하는 모델입니다.
/// 언어 / 프레임워크 / 도구와 같이 섹션 단위 구분이 필요한 경우에 사용됩니다.
struct CategoryGroup {
    /// 그룹의 제목입니다.
    let title: String

    /// 그룹에 포함된 카테고리 목록입니다.
    let categories: [Category]
}

/// 카테고리 데이터를 제공하는 저장소입니다.
/// 앱 내부에서 사용하는 정적 카테고리 목록을 관리하며,  
/// 드롭다운 메뉴나 필터 선택 기능에서 참조됩니다.
enum CategoryRepository {

    /// 프로그래밍 언어 카테고리 목록입니다.
    static let programmingLanguages: [Category] = [
        .init(name: "Swift", iconName: "SwiftLogo"),
        .init(name: "Java", iconName: "JavaLogo"),
        .init(name: "Kotlin", iconName: "KotlinLogo"),
        .init(name: "C", iconName: "CLogo"),
        .init(name: "Python", iconName: "PythonLogo"),
        .init(name: "PHP", iconName: "PHPLogo"),
        .init(name: "JavaScript", iconName: "JavaScriptLogo")
    ]

    /// 프레임워크 카테고리 목록입니다.
    static let frameworks: [Category] = [
        .init(name: "Django", iconName: "DjangoLogo"),
        .init(name: "Spring", iconName: "SpringLogo"),
        .init(name: "React", iconName: "ReactLogo"),
        .init(name: "Vue", iconName: "VuejsLogo"),
        .init(name: "Angular", iconName: "AngularLogo")
    ]

    /// 개발 도구 카테고리 목록입니다.
    static let tools: [Category] = [
        .init(name: "Docker", iconName: "DockerLogo"),
        .init(name: "Kubernetes", iconName: "KubernetesLogo"),
        .init(name: "Node.js", iconName: "NoSQLLogo")
    ]

    /// 모든 카테고리를 하나의 배열로 반환합니다.
    /// 드롭다운 등의 전체 목록 구성에 사용됩니다.
    static var allCategories: [Category] {
        programmingLanguages + frameworks + tools
    }

    /// 카테고리를 그룹 단위로 반환합니다.
    /// 섹션 기반 UI 구성 시 사용됩니다.
    static var groupedCategories: [CategoryGroup] {
        [
            CategoryGroup(title: "프로그래밍 언어", categories: programmingLanguages),
            CategoryGroup(title: "프레임워크", categories: frameworks),
            CategoryGroup(title: "도구", categories: tools)
        ]
    }

    /// 프로그래밍 언어 이름 목록입니다.
    /// 드롭다운 텍스트 구성 등에 사용됩니다.
    static var languageNames: [String] {
        programmingLanguages.map { $0.name }
    }
}
