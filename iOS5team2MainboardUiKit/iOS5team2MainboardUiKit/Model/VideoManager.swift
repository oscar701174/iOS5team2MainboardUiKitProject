//
//  VideoManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

class VideoManager {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = AppDelegate.viewContext) {
        self.context = context
    }

    func bundleURL(for video: VideoEntity) -> URL? {
        guard let raw = video.url, !raw.isEmpty else { return nil }

        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }

        let parts = raw.split(separator: ".")
        guard parts.count == 2 else { return nil }

        return Bundle.main.url(forResource: String(parts[0]), withExtension: String(parts[1]))
    }

    func seedIfNeeded() {
        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
        if (try? context.count(for: request)) ?? 0 > 0 { return }

        let seedVideos = [
            ("Swift 기초 강의", "Sample1.mp4", "Swift"),
            ("JavaScript 기초 강의", "Sample2.mp4", "JavaScript"),
            ("Java 기초 강의", "Sample3.mp4", "Java"),
            ("Kotlin 기초 강의", "Sample4.mp4", "Kotlin"),
            ("PHP 기초 강의", "Sample5.mp4", "PHP")
        ]

        for item in seedVideos {
            let video = VideoEntity(context: context)
            video.title = item.0
            video.url = item.1
            video.tag = item.2
            video.isPlay = 0
            video.text = ""
        }

        save()
    }

    func fetch(keyword: String = "") -> [VideoEntity] {
        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
        if !keyword.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", keyword)
        }
        return (try? context.fetch(request)) ?? []
    }

    func create(title: String, url: String, tag: String, text: String) {
        let video = VideoEntity(context: context)
        video.title = title
        video.url = url
        video.tag = tag
        video.isPlay = 0
        video.text = text
        save()
    }

    func updatePlayCount(for video: VideoEntity) {
        video.isPlay += 1
        save()
    }

    func delete(_ video: VideoEntity) {
        context.delete(video)
        save()
    }

    private func save() {
        try? context.save()
    }
}


#Preview {
    MainViewController()
}
