//
//  PlayerView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/10/25.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            preconditionFailure("Expected AVPlayerLayer, got \(type(of: layer))")
        }

        return layer
    }

    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
}
