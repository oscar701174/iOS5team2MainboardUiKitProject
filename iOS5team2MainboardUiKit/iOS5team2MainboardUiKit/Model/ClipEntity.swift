//
//  ClipEntity.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

/// # Overview
/// 사용자가 저장한 영상 클립 정보를 관리하는 CoreData 엔티티입니다.
///
/// # Discussion
/// `ClipEntity`는 영상의 URL, 제목, 생성 일시 등  
/// 사용자가 직접 저장한 클립 정보를 보관하기 위한 모델이며,  
/// CoreData `NSManagedObject` 기반으로 동작합니다.
///
/// 앱에서 새 클립을 생성하면 자동으로 `UUID`가 부여되며,
/// 이는 클립을 고유하게 식별하는 primary key 역할을 합니다.
///
/// # Note
/// CoreData에서 모델 정의(.xcdatamodeld)와 연결되어야 정상적으로 동작합니다.
class ClipEntity: NSManagedObject {

    /// # Overview
    /// 새 엔티티가 생성될 때 호출되며, 기본값을 초기화합니다.
    ///
    /// # Discussion
    /// - `id` 프로퍼티에 `UUID()`를 자동 할당합니다.
    /// - CoreData Insert 시점에서만 실행됩니다.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }
}
