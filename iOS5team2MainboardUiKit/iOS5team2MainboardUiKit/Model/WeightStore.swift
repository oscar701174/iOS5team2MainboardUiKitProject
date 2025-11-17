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
        didSet { save() }
    }

    private static let fileName = "clipWeights.json"

    private init() {
        load()
    }

    func add(_ value: Int, to id: String) {
        weights[id, default: 0] += value
    }

    func boost(_ ids: [String], by value: Int = 300) {
        for id in ids {
            weights[id, default: 0] += value
        }
    }

    func weight(of id: String) -> Int {
        weights[id] ?? 0
    }

    func sortedIDs(from ids: [String]) -> [String] {
        ids.sorted { weight(of: $0) > weight(of: $1) }
    }

    func reset() {
        weights.removeAll()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(weights)
            try data.write(to: WeightStore.fileURL(), options: [.atomic])
        } catch {
            print("Weight save failed:", error)
        }
    }

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

    private static func fileURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("ClipApp", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder.appendingPathComponent(fileName)
    }
}
