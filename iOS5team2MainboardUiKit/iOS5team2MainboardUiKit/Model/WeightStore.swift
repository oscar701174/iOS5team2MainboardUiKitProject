//
//  WeightStore.swift
//  iOS5team2MainboardUiKit
//
//  Created by 김대현 on 11/17/25.
//

import Foundation

final class WeightStore {
    static let shared = WeightStore()

    private var weights: [String: Int] = [:] {
        didSet { WeightStore.save() }
    }

    private static let fileName = "clipWeights.json"

    private init() {
        WeightStore.load()
    }

    // 클립 ID에 점수 추가
    func add(_ value: Int, to id: String) {
        weights[id, default: 0] += value
    }

    // 초기 가중치 (인트로)
    func boost(_ ids: [String], by value: Int = 300) {
        for id in ids {
            weights[id, default: 0] += value
        }
    }

    // 특정 클립 가중치 반환
    func weight(of id: String) -> Int {
        weights[id] ?? 0
    }

    // 클립 ID들을 가중치 기준으로 정렬
    func sortedIDs(from ids: [String]) -> [String] {
        ids.sorted { weight(of: $0) > weight(of: $1) }
    }

    private static func save() {
        do {
            let data = try JSONEncoder().encode(WeightStore.shared.weights)
            try data.write(to: fileURL(), options: [.atomic])
        } catch {
            print("Weight save failed:", error)
        }
    }

    private static func load() {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            WeightStore.shared.weights = try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            print("Weight load failed:", error)
        }
    }

    private static func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("ClipApp", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder.appendingPathComponent(fileName)
    }
}
