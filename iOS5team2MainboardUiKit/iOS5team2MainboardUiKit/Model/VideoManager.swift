//
//  VideoManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

enum VideoManager {

    static var context: NSManagedObjectContext {
        AppDelegate.viewContext
    }

    private static func bundleURLString(forFileName fileName: String) -> String? {
        let parts = fileName.split(separator: ".")
        guard parts.count == 2 else { return nil }

        let name = String(parts[0])
        let ext = String(parts[1])

        // 번들 안에 있는 Sample1.mp4 찾기
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }

        return url.absoluteString
    }

    static func seedIfNeeded() {

        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()

        if let count = try? context.count(for: request), count > 0 {
            return
        }

        // seed용 로컬 데이터 정의
        let seedVideos: [(title: String, url: String, tag: String)] = [
            ("Swift 기초 강의", "Sample1.mp4", "Swift"),
            ("JavaScript 기초 강의", "Sample2.mp4", "JavaScript"),
            ("Java 기초 강의", "Sample3.mp4", "Java"),
            ("Kotlin 기초 강의", "Sample4.mp4", "Kotlin"),
            ("PHP 기초 강의", "Sample5.mp4", "PHP")
        ]

        for item in seedVideos {
            let video = VideoEntity(context: context)
            video.title = item.title
            video.url = item.url
            video.tag = item.tag
            video.isPlay = 0
            video.text = ""

            if let urlString = bundleURLString(forFileName: item.url) {
                video.url = urlString
            } else {
                print("파일을 찾을 수 없음: \(item.url)")
                video.url = ""
            }
        }

        saveVideos()
    }

    static func fetchVideos(keyword: String = "") -> [VideoEntity] {

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

    static func updatePlayCount(for video: VideoEntity) {

        video.isPlay += 1
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

#Preview {
    MainViewController()
}
