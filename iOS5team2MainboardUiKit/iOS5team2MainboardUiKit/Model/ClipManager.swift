//
//  ClipManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import CoreData

class ClipManager {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveToClip(video: VideoEntity) {
        let clip = ClipEntity(context: context)
        clip.video = video
        try? context.save()
    }

    func createClip(
            video: VideoEntity,
            title: String,
            startSeconds: Double,
            endSeconds: Double
        ) {
            let clip = ClipEntity(context: context)

            clip.title = title
            clip.startSeconds = startSeconds
            clip.endSeconds = endSeconds
            clip.video = video

            try? context.save()
    }

    func fetchClips(for video: VideoEntity) -> [ClipEntity] {
        let request: NSFetchRequest<ClipEntity> = ClipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "video == %@", video)
        return (try? context.fetch(request)) ?? []
    }

    func delete(_ clip: ClipEntity) {
        context.delete(clip)
        try? context.save()
    }
}

