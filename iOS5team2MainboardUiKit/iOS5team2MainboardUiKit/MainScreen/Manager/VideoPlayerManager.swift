//
//  VideoPlayerManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import Foundation
import AVFoundation
import AVKit

class VideoPlayerManager: NSObject, AVPlayerViewControllerDelegate {

    private(set) var player: AVPlayer?
    private var timeObserver: Any?
    private var wasPlayingBeforeFullScreen = false

    var isScrubbing = false
    var didReachEnd = false

    var onProgressChanged: ((Float, String) -> Void)?

    var onDurationLoaded: ((String) -> Void)?

    var onPlayEnded: (() -> Void)?

    var onPlayStateChanged: ((Bool) -> Void)?

    deinit {
        if let obs = timeObserver, let player {
            player.removeTimeObserver(obs)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func startPlayback(with url: URL? = nil) {

        guard  let defaultURL = URL(string: "https://example.com/default.mp4") else {
            return
        }

        let finalURL = url ?? defaultURL

        let playerItem = AVPlayerItem(url: finalURL)
        let player = AVPlayer(playerItem: playerItem)

        if let oldPlayer = self.player, let obs = timeObserver {
            oldPlayer.removeTimeObserver(obs)
            timeObserver = nil
        }

        self.player = player

        addProgressObserver()
        addPlayEndObserver()

        Task {
            do {
                let duration = try await playerItem.asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)

                if durationSeconds.isFinite && durationSeconds > 0 {
                    let text = TimeFormatter.timeFormat(durationSeconds)
                    self.onDurationLoaded?(text)
                }
            } catch {
                print("Failed to load duration:", error)
            }
        }
    }

    func addProgressObserver() {

        guard let player = player else { return }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in

            guard let self else { return }
            guard !self.isScrubbing, let item = player.currentItem else {
                return
            }

            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else {
                return
            }

            let current = player.currentTime().seconds
            let progress = max(0, min(1, Float(current/duration)))
            let currentText = TimeFormatter.timeFormat(current)
            self.onProgressChanged?(progress, currentText)

        }
    }

    func addPlayEndObserver() {
        guard let playerItem = player?.currentItem else {
            return
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.onPlayEnded?()
        }
    }

    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        guard durationSeconds.isFinite else { return }

        let currentTime = player.currentTime().seconds
        let newTime = min(currentTime + 10, durationSeconds - 0.1)
        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func skipRewindSeconds(player: AVPlayer) {
        let currentTime = player.currentTime().seconds
        let newTime = max(currentTime - 10, 0)

        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func presentFullScreenPlayer(from viewController: UIViewController, player: AVPlayer) {
        let pvc = AVPlayerViewController()

        pvc.player = player
        pvc.delegate = self
        pvc.showsPlaybackControls = true
        pvc.allowsPictureInPicturePlayback = true
        pvc.entersFullScreenWhenPlaybackBegins = false
        pvc.exitsFullScreenWhenPlaybackEnds = true
        pvc.modalPresentationStyle = .fullScreen
        pvc.showsPlaybackControls = true
        player.allowsExternalPlayback = false

        viewController.present(pvc, animated: true) { player.play() }
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator) {

        var wasPlaying: Bool

        if let player = playerViewController.player {
            wasPlaying = (player.timeControlStatus == .playing || player.rate > 0)
        } else {
            wasPlaying = false
        }

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self, let player = self.player else { return }

            if wasPlaying {
                player.play()
                self.onPlayStateChanged?(true)
            } else {
                player.pause()
                self.onPlayStateChanged?(false)
            }
        }
    }

    func changeSpeed(to rate: Double) {
        player?.rate = Float(rate)
    }

}

#Preview {
    MainViewController()
}
