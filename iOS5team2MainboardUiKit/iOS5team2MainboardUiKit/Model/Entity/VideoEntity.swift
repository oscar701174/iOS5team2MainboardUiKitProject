//
//  VideoEntity+CoreDataClass.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

/// # Overview
/// 앱에서 사용되는 영상 정보를 저장하는 CoreData 엔티티입니다.
///
/// # Discussion
/// `VideoEntity`는 영상 제목, 파일 URL, 태그(Swift, Kotlin 등),  
/// 재생 여부 등의 메타데이터를 관리하기 위한 모델입니다.  
/// 실제 영상 파일은 번들 또는 외부 URL에 존재하며,  
/// 이 엔티티는 그 파일에 대한 참조를 저장하는 역할을 합니다.
///
/// Entity 생성 시 고유 식별자(UUID)가 자동으로 부여되며,  
/// 이는 CoreData 관계(예: ClipEntity → VideoEntity)에서도 활용됩니다.
///
/// # Note
/// 실제 속성들(id, title, url, tag 등)은  
/// `.xcdatamodeld`에서 정의된 구조를 따릅니다.
class VideoEntity: NSManagedObject {

    /// # Overview
    /// 새 VideoEntity가 Insert될 때 호출되며,
    /// 기본 식별자를 자동으로 생성합니다.
    ///
    /// # Discussion
    /// - `id`는 클립 저장/필터링/정렬 등 다양한 기능에서 사용됩니다.
    /// - Insert 시점에만 실행됩니다.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }
}
