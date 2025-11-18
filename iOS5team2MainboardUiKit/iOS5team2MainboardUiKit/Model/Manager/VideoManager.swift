//
//  VideoManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

/// # Overview
/// 영상(VideoEntity) 데이터를 CoreData에서 관리하는 매니저 클래스입니다.
///
/// # Responsibilities
/// - 앱 실행 시 초기 Seed 데이터 삽입  
/// - 영상 목록 조회(fetch)  
/// - 영상 생성(create)  
/// - 재생 횟수 업데이트  
/// - 영상 삭제  
/// - 영상 파일의 실제 URL 변환(bundle or remote)
///
/// # Discussion
/// ViewController 또는 ViewModel에서 직접 CoreData를 다루지 않고,  
/// 이 매니저를 통해서만 VideoEntity를 생성/조회/삭제하도록 구조화되어 있습니다.
///
/// 앱의 모든 영상 관련 로직을 한 곳에서 관리할 수 있어 유지보수가 용이합니다.
///
/// # Note
/// context 기본값은 `AppDelegate.viewContext`이며,  
/// 필요하면 테스트용 context를 주입해 단위 테스트도 가능합니다.
class VideoManager {

    // MARK: - Properties

    /// CoreData 컨텍스트
    private let context: NSManagedObjectContext

    // MARK: - Initializer

    /// # Overview
    /// CoreData 컨텍스트를 주입받습니다.
    /// 기본값으로 AppDelegate의 viewContext를 사용합니다.
    init(context: NSManagedObjectContext = AppDelegate.viewContext) {
        self.context = context
    }

    // MARK: - URL Resolver

    /// # Overview
    /// VideoEntity에 저장된 문자열 기반 URL을 실제 `URL` 객체로 변환합니다.
    ///
    /// # Discussion
    /// - http / https 로 시작하면 원격 URL로 처리합니다.  
    /// - 그렇지 않으면 앱 번들 내의 파일("Sample1.mp4" 등)을 참조합니다.
    ///
    /// # Returns
    /// - 유효한 URL 객체 또는 nil
    func bundleURL(for video: VideoEntity) -> URL? {
        guard let raw = video.url, !raw.isEmpty else { return nil }

        // 1) Local absolute file URL (Documents)
        if raw.hasPrefix("file:///") {
            if let url = URL(string: raw) {
                return FileManager.default.fileExists(atPath: url.path) ? url : nil
            }
        }

        // 2) Remote http URL
        
        
        // 완전한 URL일 경우
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }

        // "파일명.확장자" 구조 확인
        let parts = raw.split(separator: ".")
        guard parts.count == 2 else { return nil }

        return Bundle.main.url(
            forResource: String(parts[0]),
            withExtension: String(parts[1])
        )
    }

    // MARK: - Seed Data

    /// # Overview
    /// 앱 최초 실행 시 기본 영상 데이터를 삽입합니다.
    ///
    /// # Discussion
    /// 이미 데이터가 존재하면 아무 작업도 하지 않습니다.
    /// 개발/테스트용 샘플 데이터를 제공하는 용도로 사용합니다.
    func seedIfNeeded() {
        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()

        // 기존 데이터가 하나라도 있으면 seed skip
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
            video.isPlay = 0     // 재생 횟수 초기화
            video.text = ""      // 기본 설명 비움
        }

        save()
    }

    // MARK: - Fetch

    /// # Overview
    /// 영상 목록을 불러옵니다.
    ///
    /// # Parameters
    /// - keyword: 제목 검색을 위한 문자열 (기본값: "")
    ///
    /// # Returns
    /// - 키워드가 비어 있으면 전체 목록  
    /// - 키워드가 있으면 해당 텍스트가 포함된 영상 목록
    func fetch(keyword: String = "") -> [VideoEntity] {
        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()

        if !keyword.isEmpty {
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@", keyword
            )
        }

        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Create

    /// # Overview
    /// 새로운 영상을 생성하여 CoreData에 저장합니다.
    func create(title: String, url: String, tag: String, text: String) {
        let video = VideoEntity(context: context)
        video.title = title
        video.url = url
        video.tag = tag
        video.isPlay = 0
        video.text = text

        save()
    }

    
    
    func create(from model: VideoModel) {
        let entity = VideoEntity(context: context)
        entity.id = model.id
        entity.title = model.title
        entity.url = model.filePath.absoluteString
        entity.tag = model.tag
        entity.isPlay = 0
        entity.text = ""

        save()
    }
    
    
    // MARK: - Update

    /// # Overview
    /// 영상 재생 횟수를 1 증가시킵니다.
    func updatePlayCount(for video: VideoEntity) {
        video.isPlay += 1
        save()
    }

    // MARK: - Delete

    /// # Overview
    /// 특정 영상을 CoreData에서 삭제합니다.
    func delete(_ video: VideoEntity) {
        context.delete(video)
        save()
    }

    // MARK: - CoreData Save

    /// # Overview
    /// 컨텍스트 변경사항을 저장합니다.
    ///
    /// # Note
    /// 오류는 단순 처리(try?)로 무시하고 있습니다.
    /// 필요하다면 do/catch로 확장 가능합니다.
    private func save() {
        try? context.save()
    }
}

#Preview {
    MainViewController()
}
