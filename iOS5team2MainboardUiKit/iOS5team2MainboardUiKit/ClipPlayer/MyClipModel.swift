import Foundation
import AVFoundation

struct ClipModel: Decodable {
    var id: UUID = UUID()
<<<<<<< HEAD:iOS5team2MainboardUiKit/iOS5team2MainboardUiKit/ClipLibrary/MyClipModel.swift
    let filePath: URL
    let start: String
    let end: String
    var asset: AVURLAsset {
        AVURLAsset(url: filePath)
    }
=======
    let start: Double
    let end: Double
>>>>>>> clipPlayer:iOS5team2MainboardUiKit/iOS5team2MainboardUiKit/ClipPlayer/MyClipModel.swift
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
