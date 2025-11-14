//
//  Languages.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/13/25.
//

import UIKit

struct Category {
    let name: String
    let iconName: String
}

struct CategoryGroup {
    let title: String
    let categories: [Category]
}

enum CategoryRepository {
    static let programmingLanguages: [Category] = [
        .init(name: "Swift", iconName: "SwiftLogo"),
        .init(name: "Java", iconName: "JavaLogo"),
        .init(name: "Kotlin", iconName: "KotlinLogo"),
        .init(name: "C", iconName: "CLogo"),
        .init(name: "Python", iconName: "PythonLogo"),
        .init(name: "PHP", iconName: "PHPLogo"),
        .init(name: "JavaScript", iconName: "JavaScriptLogo")
    ]
    static let frameworks: [Category] = [
        .init(name: "Django", iconName: "DjangoLogo"),
        .init(name: "Spring", iconName: "SpringLogo"),
        .init(name: "React", iconName: "ReactLogo"),
        .init(name: "Vue", iconName: "VuejsLogo"),
        .init(name: "Angular", iconName: "AngularLogo")
    ]
    static let tools: [Category] = [
        .init(name: "Docker", iconName: "DockerLogo"),
        .init(name: "Kubernetes", iconName: "KubernetesLogo"),
        .init(name: "Node.js", iconName: "NoSQLLogo")
    ]
    static var allCategories: [Category] {
        return programmingLanguages + frameworks + tools
    }
    static var groupedCategories: [CategoryGroup] {
        return [
            CategoryGroup(title: "프로그래밍 언어", categories: programmingLanguages),
            CategoryGroup(title: "프레임워크", categories: frameworks),
            CategoryGroup(title: "도구", categories: tools)
        ]
    }
    static var languageNames: [String] {
        return programmingLanguages.map { $0.name }
    }
}
