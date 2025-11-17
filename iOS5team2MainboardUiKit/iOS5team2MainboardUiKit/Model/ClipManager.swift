//
//  ClipManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import CoreData

/// # Overview
/// 사용자가 저장한 영상 클립(ClipEntity)을 생성, 조회, 삭제하는 CoreData 전용 매니저입니다.
///
/// # Discussion
/// 이 매니저는 `ClipEntity` 생성과 조회 로직을 캡슐화하여  
/// ViewController나 특정 비즈니스 로직에서 CoreData를 직접 다루지 않도록 합니다.
///
/// 내부적으로 `NSManagedObjectContext`를 주입받아 동작하며,  
/// 기본값으로 `AppDelegate.viewContext`를 사용합니다.
///
/// 주요 기능:
/// - 클립 생성 및 저장
/// - 특정 영상(VideoEntity)에 속한 클립 목록 조회
/// - 클립 삭제
///
/// # Note
/// 모든 저장/삭제는 `try? context.save()` 기반으로 처리되며,  
/// 에러 처리가 필요한 경우 별도 전략을 추가해 확장할 수 있습니다.
class ClipManager {

    // MARK: - Properties

    /// CoreData 작업에 사용되는 컨텍스트
    private let context: NSManagedObjectContext

    // MARK: - Initializer

    /// # Overview
    /// ClipManager 인스턴스를 초기화합니다.
    ///
    /// - Parameter context: 사용할 CoreData 컨텍스트 (기본값: `AppDelegate.viewContext`)
    init(context: NSManagedObjectContext = AppDelegate.viewContext) {
        self.context = context
    }

    // MARK: - CRUD

    /// # Overview
    /// 지정된 `VideoEntity`를 기반으로 새로운 클립을 생성하고 저장합니다.
    ///
    /// # Discussion
    /// 클립의 시간 정보가 필요 없는 단순 저장 시 사용하는 메서드입니다.
    ///
    /// - Parameter video: 클립이 연결될 VideoEntity
    func saveToClip(video: VideoEntity) {
        let clip = ClipEntity(context: context)
        clip.video = video
        try? context.save()
    }

    /// # Overview
    /// 지정된 시간 구간(start/end)으로 클립을 생성하고 저장합니다.
    ///
    /// # Parameters
    /// - video: 소스 영상 엔티티
    /// - title: 사용자 지정 클립 제목
    /// - startSeconds: 시작 시각(초 단위)
    /// - endSeconds: 종료 시각(초 단위)
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

    /// # Overview
    /// 특정 영상(VideoEntity)에 연결된 모든 클립 목록을 반환합니다.
    ///
    /// # Discussion
    /// `ClipEntity.video == video` 조건으로 필터링합니다.
    ///
    /// - Parameter video: 클립을 조회할 대상 영상
    /// - Returns: 해당 영상에 연결된 클립 리스트
    func fetchClips(for video: VideoEntity) -> [ClipEntity] {
        let request: NSFetchRequest<ClipEntity> = ClipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "video == %@", video)
        return (try? context.fetch(request)) ?? []
    }

    /// # Overview
    /// 지정된 클립을 CoreData에서 삭제합니다.
    ///
    /// - Parameter clip: 삭제할 클립 엔티티
    func delete(_ clip: ClipEntity) {
        context.delete(clip)
        try? context.save()
    }
}
