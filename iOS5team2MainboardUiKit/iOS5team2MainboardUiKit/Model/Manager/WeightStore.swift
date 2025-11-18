//
//  WeightStore.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/17/25.
//

import Foundation

/// 사용자의 언어/카테고리 선호도를 저장하고 관리하는 클래스입니다.
/// 내부적으로 각 언어/카테고리에 대해 정수형 가중치(weight)를 부여하여
/// 자주 사용하는 항목이 더 우선순위로 정렬되도록 합니다.
///
/// 데이터는 앱의 Application Support 디렉토리에 JSON 형태로 저장됩니다.
final class WeightStore {
    static let shared = WeightStore()  // 싱글톤 인스턴스

    /// 언어 또는 태그에 대한 가중치를 저장하는 딕셔너리
    private var weights: [String: Int] = [:] {
        didSet { save() }  // 변경 시 자동 저장
    }

    /// JSON 파일 이름
    private static let fileName = "languageWeights.json"

    /// 생성자: 앱 시작 시 저장된 가중치를 불러옵니다.
    private init() {
        load()
    }

    // MARK: - Public Methods

    /// 특정 언어/태그에 가중치를 추가합니다.
    func add(_ value: Int, to language: String) {
        weights[language, default: 0] += value
    }

    /// 여러 언어/태그에 동일한 가중치를 일괄적으로 부여합니다.
    func boost(_ languages: [String], by value: Int = 300) {
        for lang in languages {
            weights[lang, default: 0] += value
        }
    }

    /// 특정 언어/태그의 현재 가중치를 반환합니다.
    func weight(of language: String) -> Int {
        weights[language] ?? 0
    }

    /// 전달된 ID 배열을 가중치 순서대로 정렬합니다. (높은 순서 → 낮은 순서)
    func sortedLanguages(from ids: [String]) -> [String] {
        ids.sorted { weight(of: $0) > weight(of: $1) }
    }

    /// 모든 저장된 가중치를 초기화합니다.
    func reset() {
        weights.removeAll()
        save()
    }

    // MARK: - Persistence (File 저장/불러오기)

    /// 현재 가중치 딕셔너리를 JSON으로 저장합니다.
    private func save() {
        do {
            let data = try JSONEncoder().encode(weights)
            try data.write(to: Self.fileURL(), options: [.atomic])
        } catch {
            print("WeightStore save failed:", error)
        }
    }

    /// 저장된 JSON 파일에서 가중치를 불러옵니다.
    private func load() {
        let url = Self.fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            weights = try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            print("WeightStore load failed:", error)
        }
    }

    /// 저장/불러오기용 JSON 파일 경로를 반환합니다.
    private static func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("ClipApp", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder.appendingPathComponent(fileName)
    }
}
