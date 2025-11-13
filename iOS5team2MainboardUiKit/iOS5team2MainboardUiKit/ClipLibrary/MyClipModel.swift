import Foundation
import AVFoundation

struct ClipModel: Decodable {
    var id: UUID = UUID()
    let filePath: URL
    let start: String
    let end: String
    var asset: AVURLAsset {
        AVURLAsset(url: filePath)
    }
}

struct VideoModel: Decodable {
    var id: UUID = UUID()
    let title: String
    let filePath: URL
    let clips: [ClipModel]?
}
