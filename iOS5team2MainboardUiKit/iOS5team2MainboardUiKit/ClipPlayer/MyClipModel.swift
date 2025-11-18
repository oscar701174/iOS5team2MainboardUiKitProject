import Foundation
import AVFoundation

/// # ClipModel
/// 하나의 영상 클립(시작~끝 구간)을 표현하는 데이터 모델입니다.
/// 주로 영상 내 특정 구간을 저장/재생하기 위한 용도로 사용됩니다.
struct ClipModel: Decodable {
    /// 클립 고유 ID (자동 생성됨)
    var id: UUID = UUID()

    /// 클립 시작 시간 (초 단위)
    let start: Double

    /// 클립 종료 시간 (초 단위)
    let end: Double

    /// 클립에 대한 사용자 정의 제목 (옵션)
    var title: String?
}

/// # VideoModel
/// 하나의 전체 영상 파일을 표현하는 모델입니다.
/// 영상의 파일 경로, 언어 태그, 클립 리스트 등을 포함합니다.
struct VideoModel: Decodable {
    /// 영상 고유 ID (자동 생성됨)
    var id: UUID = UUID()

    /// 영상 제목
    let title: String

    /// 영상 파일의 실제 경로 (로컬 또는 번들 내 URL)
    let filePath: URL

    /// 영상의 언어 또는 카테고리 태그 (정렬 및 분류에 사용)
    let tag: String

    /// 이 영상에 포함된 클립 목록 (옵션)
    var clips: [ClipModel]? = []
}
