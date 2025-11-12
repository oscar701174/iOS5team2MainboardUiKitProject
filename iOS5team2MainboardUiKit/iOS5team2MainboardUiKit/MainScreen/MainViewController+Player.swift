//
//  MainViewController+Player.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import AVFoundation
import AVKit
import UIKit

extension MainViewController: AVPlayerViewControllerDelegate {

    func startPlayback(with urlOverride: URL? = nil) {

        let defaultURL = URL(string: "https://kxc.blob.core.windows.net/est2/video.mp4")
        guard let url = urlOverride ?? playingVideoURL ?? defaultURL else {
            print(" 유효한 재생 URL이 없습니다.")
            return
        }

            playingVideoURL = url

            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)

            self.player = player
            mainView.playerView.player = player

            addProgressObserver(to: player)
            addPlayEndObserver()

            Task {
                do {
                    let duration = try await playerItem.asset.load(.duration)
                    let durationSeconds = CMTimeGetSeconds(duration)

                    if durationSeconds.isFinite && durationSeconds > 0 {
                        self.mainView.end.text = TimeFormatter.timeFormat(durationSeconds)
                    }
                } catch {
                    print("Failed to load duration:", error)
                }
            }
        }

    func addProgressObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] _ in
            guard let self else { return }
            guard !self.isScrubbing, let item = player.currentItem else {
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

    func presentFullScreenPlayer(from viewCon: UIViewController, player: AVPlayer) {
        let pvc = AVPlayerViewController()

        pvc.player = player
        pvc.delegate = self
        pvc.showsPlaybackControls = true
        pvc.allowsPictureInPicturePlayback = true
        pvc.entersFullScreenWhenPlaybackBegins = false
        pvc.exitsFullScreenWhenPlaybackEnds = true
        pvc.modalPresentationStyle = .fullScreen

        if player.timeControlStatus == .playing || player.rate > 0 {
            wasPlayingBeforeFullScreen = true
        }
        viewCon.present(pvc, animated: true) {
            player.play()
        }
    }

    func resumePlayBackAfterFullScreen() {
        guard wasPlayingBeforeFullScreen else { return }
        guard let player = self.player else { return }

        player.automaticallyWaitsToMinimizeStalling = true
        player.currentItem?.preferredForwardBufferDuration = 2

        player.playImmediately(atRate: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.player?.timeControlStatus != .playing {
                self.player?.play()
            }
        }
        wasPlayingBeforeFullScreen = false
    }

}

#Preview {
    MainViewController()
}
