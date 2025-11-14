//
//  ClipManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import CoreData

enum ClipManager {

    static var context = AppDelegate.viewContext

    static func fetchClips(for video: VideoEntity) -> [ClipEntity] {

        let request: NSFetchRequest<ClipEntity> = ClipEntity.fetchRequest()

        request.predicate = NSPredicate(
            format: "video == %@", video
        )

        do {
            return try context.fetch(request)
        } catch {
            print(" ClipEntity 불러오기 실패:", error)
            return []
        }
    }

    static func createClips(title: String, startSeconds: Double, endSeconds: Double ) {

        let clip = ClipEntity(context: context)

        clip.title = title
        clip.startSeconds = startSeconds
        clip.endSeconds = endSeconds

        saveClips()
    }

    static func saveClips() {

        do {
            return try context.save()
        } catch {
            print("저장 실패", error)
        }
    }

    static func deleteClips() {
        let clip = ClipEntity(context: context)

        context.delete(clip)

        saveClips()
    }
}
