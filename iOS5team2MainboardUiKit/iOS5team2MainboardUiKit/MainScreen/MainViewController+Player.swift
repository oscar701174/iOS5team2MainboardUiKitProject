//
//  MainViewController+Player.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import AVFoundation
import UIKit

extension MainViewController {

    func addProgressObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)

        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] _ in
            guard let self, let item = player.currentItem else {
                return
            }

            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else {
                return
            }

            mainView.progressSlider.value = max(0, min(1, Float(player.currentTime().seconds / item.duration.seconds)))
            mainView.start.text = TimeFormatter.timeFormat(player.currentTime().seconds)

        }
    }

    func addPlayEndObserver() {
        guard let playerItem = player?.currentItem else {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        guard durationSeconds.isFinite else { return }

        let currentTime = player.currentTime().seconds
        let newTime = min(currentTime + 15, durationSeconds - 0.1)
        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func skipRewindSeconds(player: AVPlayer) {
        let currentTime = player.currentTime().seconds
        let newTime = max(currentTime - 15, 0)

        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
