import Foundation
import AVFoundation

struct ClipModel: Decodable {
    var id: UUID = UUID()
    let start: Double
    let end: Double
    var title: String?
}

struct VideoModel: Decodable {
    var id: UUID = UUID()
    let title: String
    let filePath: URL
    let tag: String
    var clips: [ClipModel]? = []
}
