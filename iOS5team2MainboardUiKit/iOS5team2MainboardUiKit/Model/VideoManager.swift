//
//  VideoManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

enum VideoManager {

    static var context = AppDelegate.viewContext

    static func seedIfNeeded() {

        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()

        if let count = try? context.count(for: request), count > 0 {
            return
        }

        // 여기에 seed용 로컬 데이터 정의
        let seedVideos: [(title: String, url: String, tag: String)] = [
            ("Swift 기초 강의 1", "local://video1.mp4", "Swift"),
            ("Swift 기초 강의 2", "local://video2.mp4", "Swift"),
            ("iOS 레이아웃 기초", "local://video3.mp4", "UIKit")
        ]

        for item in seedVideos {
            let video = VideoEntity(context: context)
            video.id = UUID()
            video.title = item.title
            video.url = item.url
            video.tag = item.tag
            video.isPlay = 0
            video.text = ""
        }

        saveVideos()
    }

    static func fetchVideos(keyword: String) -> [VideoEntity] {

        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()

        if !keyword.isEmpty {
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@", keyword
            )
        }

        return (try? context.fetch(request)) ?? []
    }

    static func createVideos(title: String, url: String, tag: String, text: String) {
        let video = VideoEntity(context: context)
        video.title = title
        video.url = url
        video.tag = tag
        video.isPlay = 0
        video.text = text

        saveVideos()
    }

    static func saveVideos() {
        do {
            try context.save()
        } catch {
            print("저장 실패")
        }
    }

}
