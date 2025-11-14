import Foundation
import AVFoundation

struct ClipModel: Decodable {
    var id: UUID = UUID()
    let start: Double
    let end: Double
}

struct VideoModel: Decodable {
    var id: UUID = UUID()
    let title: String
    let filePath: URL
    var clips: [ClipModel]? = [
        ClipModel(start: 5.0, end: 10.0),
        ClipModel(start: 12.0, end: 18.0)
    ]
}

