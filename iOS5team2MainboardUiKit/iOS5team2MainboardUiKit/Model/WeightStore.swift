//
//  WeightStore.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/17/25.
//

import Foundation

/// # Overview
/// 특정 클립(영상)에 대한 **가중치 점수(weight)**를 저장하고 관리하는 전용 스토리지입니다.
///
/// # Discussion
/// 이 클래스는 앱 내부에서 “추천 정렬”, “최근 재생된 영상 강조”,
/// “사용자가 자주 보는 영상의 우선 순위 매기기” 등에 활용할 수 있도록
/// **클립 ID(String) → 가중치(Int)** 구조로 저장합니다.
///
/// 저장 방식은 다음과 같습니다:
/// - JSON 파일(`Application Support/ClipApp/clipWeights.json`)에 자동 저장
/// - 앱 재실행 시 파일을 불러와 이전 상태 복원
/// - `add`, `boost` 등 가중치 변경 시마다 즉시 `save()` 호출
///
/// 싱글턴 패턴(`shared`)으로 제공되므로
/// 앱 전체에서 하나의 인스턴스를 공유하여 동작합니다.
final class WeightStore {

    /// # Overview
    /// WeightStore의 전역(shared) 인스턴스입니다.
    ///
    /// # Note
    /// 싱글턴 패턴을 사용하며, 항상 동일한 객체를 공유합니다.
    static let shared = WeightStore()

    /// # Overview
    /// 클립 ID(String)별 가중치(Int)를 저장하는 딕셔너리입니다.
    ///
    /// # Discussion
    /// - 값이 변경될 때마다 `didSet`에 의해 자동으로 저장됩니다.
    /// - 키: 클립 고유 ID
    /// - 값: 해당 클립에 누적된 점수
    private var weights: [String: Int] = [:] {
        didSet { save() }
    }

    /// JSON 파일 이름
    private static let fileName = "clipWeights.json"

    /// # Overview
    /// 초기화 시 기존 저장 파일을 자동으로 불러옵니다.
    ///
    /// # Note
    /// 외부에서 생성하지 못하도록 `private init`을 적용합니다.
    private init() {
        load()
    }

    // MARK: - Public Methods

    /// # Overview
    /// 특정 클립 ID에 점수를 추가합니다.
    ///
    /// # Parameters
    /// - value: 더할 점수
    /// - id: 점수를 더할 클립 ID
    ///
    /// # Discussion
    /// 점수 변경 후 자동 저장됩니다.
    func add(_ value: Int, to id: String) {
        weights[id, default: 0] += value
    }

    /// # Overview
    /// 여러 클립 ID에 동일한 점수를 일괄로 추가합니다.
    ///
    /// # Parameters
    /// - ids: 점수를 부여할 클립 ID 리스트
    /// - value: 기본값 300. (강하게 띄우고 싶은 클립에 사용)
    ///
    /// # Use Case
    /// 앱 첫 실행 시 특정 클립을 “추천”으로 올리고 싶을 때 활용합니다.
    func boost(_ ids: [String], by value: Int = 300) {
        for id in ids {
            weights[id, default: 0] += value
        }
    }

    /// # Overview
    /// 특정 클립의 가중치 값을 반환합니다.
    ///
    /// # Parameters
    /// - id: 조회할 클립 ID
    ///
    /// # Returns
    /// 가중치 값. 없으면 0을 반환합니다.
    func weight(of id: String) -> Int {
        weights[id] ?? 0
    }

    /// # Overview
    /// 전달받은 ID 목록을 가중치 순서(높은 → 낮은)로 정렬해서 반환합니다.
    ///
    /// # Parameters
    /// - ids: 정렬할 클립 ID 목록
    ///
    /// # Returns
    /// 가중치 높은 순으로 정렬된 ID 배열
    ///
    /// # Use Case
    /// “추천 영상 우선 정렬” 등에 사용될 수 있습니다.
    func sortedIDs(from ids: [String]) -> [String] {
        ids.sorted { weight(of: $0) > weight(of: $1) }
    }

    /// # Overview
    /// 모든 가중치를 초기화합니다.
    ///
    /// # Discussion
    /// 데이터는 즉시 JSON 파일에서 삭제됩니다.
    func reset() {
        weights.removeAll()
        save()
    }

    // MARK: - File Handling

    /// # Overview
    /// 현재 weights 딕셔너리를 JSON 파일로 저장합니다.
    ///
    /// # Note
    /// 파일 저장 경로는 `Application Support/ClipApp/clipWeights.json`
    private func save() {
        do {
            let data = try JSONEncoder().encode(weights)
            try data.write(to: WeightStore.fileURL(), options: [.atomic])
        } catch {
            print("Weight save failed:", error)
        }
    }

    /// # Overview
    /// 저장된 JSON 파일을 불러와 weights 딕셔너리를 복원합니다.
    private func load() {
        let url = WeightStore.fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            weights = try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            print("Weight load failed:", error)
        }
    }

    /// # Overview
    /// 가중치 저장 파일의 절대 경로(URL)를 생성합니다.
    ///
    /// # Discussion
    /// - Application Support 디렉토리 내에 `ClipApp` 폴더 생성
    /// - 그 안에 `clipWeights.json` 파일 저장
    ///
    /// # Returns
    /// JSON 파일의 URL
    private static func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("ClipApp", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder.appendingPathComponent(fileName)
    }
}
