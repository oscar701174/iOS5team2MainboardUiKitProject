import UIKit
import SwiftUI
import AVKit
import AVFoundation
import CoreMedia

class ClipPlayer {
    var playerMode: PlayerMode = .auto
    var playLoopMode: PlayLoopMode = .off

    static let shared = ClipPlayer()

    private var playerViewControllerIfLoaded: AVPlayerViewController?

    private func loadPlayerViewControllerIfNeeded() {
        if playerViewControllerIfLoaded == nil {
            playerViewControllerIfLoaded = AVPlayerViewController()
        }
    }

    weak var delegate: ClipPlayerDelegate?

    var video: VideoModel? {
        didSet {
            try? loadVideo()
        }
    }

    var durationTimeToEnd: CMTime?

    private(set) var playerSetStates: States = [] {
        didSet {
            delegate?.clipPlayer(self, didChangeState: playerSetStates)
        }
    }

    private var playerObservation: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var loopObserver: Any?

    private init() {}
}

// MARK: - Delegate 정의

protocol ClipPlayerDelegate: AnyObject {
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool)
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States)
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint: CMTime)
    func clipPlayer(_ clipPlayer: ClipPlayer, durationToPlayToEnd: CMTime)
}

extension ClipPlayerDelegate {
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint: CMTime) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, durationToplayToEnd: CMTime) {}
}

// MARK: - 재생 중인 영상 비교

extension AVPlayerViewController {
    func hasSameContent(fromVideo video: VideoModel) -> Bool {
        guard let currentItemURLAsset = player?.currentItem?.asset as? AVURLAsset else {
            return false
        }
        return currentItemURLAsset.url == video.filePath
    }
}

// MARK: - 상태

struct States: OptionSet {
    let rawValue: Int
    static let embeddedInline = States(rawValue: 1 << 0)
    static let videoLoaded = States(rawValue: 1 << 1)
    static let playing = States(rawValue: 1 << 2)
    static let paused = States(rawValue: 1 << 3)
}

// MARK: - 뷰 삽입

extension ClipPlayer {
    private func removeFromParentIfNeeded() {
        guard let vc = playerViewControllerIfLoaded else { return }
        if vc.parent != nil {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }

    func embedInline(in parent: UIViewController, container: UIView) {
        loadPlayerViewControllerIfNeeded()
        guard let playerViewController = playerViewControllerIfLoaded,
              playerViewController.parent != parent else { return }

        removeFromParentIfNeeded()
        playerSetStates.insert(.embeddedInline)

        parent.addChild(playerViewController)
        container.addSubview(playerViewController.view)
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerViewController.view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playerViewController.view.widthAnchor.constraint(equalTo: container.widthAnchor),
            playerViewController.view.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        playerViewController.didMove(toParent: parent)
    }
}

// MARK: - 시간 관찰자

extension ClipPlayer {
    private func addTimeObserver() {
        guard let player = playerViewControllerIfLoaded?.player else { return }

        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.delegate?.clipPlayer(self, currentPlayingTimePoint: time)
        }
    }
}

// MARK: - Video 로딩 / 재생

extension ClipPlayer {
    func loadVideo() throws {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.embeddedInline) else { return }
        guard let video else { return }

        if playerVC.hasSameContent(fromVideo: video) { return }

        let newVideo = AVPlayerItem(url: video.filePath)

        Task {
            let duration = try await newVideo.asset.load(.duration)
            self.durationTimeToEnd = duration
            self.delegate?.clipPlayer(self, durationToPlayToEnd: duration)
        }

        if let player = playerVC.player {
            player.replaceCurrentItem(with: newVideo)
        } else {
            playerVC.player = AVPlayer(playerItem: newVideo)
        }

        playerObservation?.invalidate()
        playerObservation = newVideo.observe(\.status, changeHandler: { [weak self] item, _ in
            guard let self else { return }

            switch item.status {
            case .readyToPlay:
                DispatchQueue.main.async {
                    self.playerSetStates.insert(.videoLoaded)
                    self.delegate?.clipPlayer(self, didVideoLoaded: true)
                    self.addTimeObserver()
                    if self.playerMode == .auto {
                        self.startPlaying()
                    }
                }
            case .failed:
                self.delegate?.clipPlayer(self, didVideoLoaded: false)
            default:
                return
            }
        })
    }

    func startPlaying() {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.videoLoaded) else { return }

        playerVC.player?.play()
        playerSetStates.insert(.playing)
    }

    func stopPlaying() {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.playing) else { return }

        playerVC.player?.pause()
        playerSetStates.insert(.paused)
    }

    func playClip(_ clip: ClipModel) {
        guard
            let playerVC = playerViewControllerIfLoaded,
            playerSetStates.contains(.videoLoaded),
            let player = playerVC.player
        else { return }

        // 기존 재생 중지
        player.pause()

        let start = CMTime(seconds: clip.start, preferredTimescale: 600)
        let end = CMTime(seconds: clip.end, preferredTimescale: 600)

        // 정확한 위치로 이동
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        // 언어 가중치 분당 1점 추가
        if let lang = video?.tag {
            let duration = clip.end - clip.start
            let perMinuteScore = Int(duration / 60.0)
            if perMinuteScore > 0 {
                WeightStore.shared.add(perMinuteScore, to: lang)
            } else {
                WeightStore.shared.add(1, to: lang)  // 최소 1점 보장
            }
        }

        // loop observer 제거
        if let token = loopObserver {
            player.removeTimeObserver(token)
            loopObserver = nil
        }

        // 루프 재생 여부
        switch playLoopMode {
        case .on:
            loopObserver = player.addBoundaryTimeObserver(forTimes: [NSValue(time: end)], queue: .main) { [weak self] in
                guard let self else { return }
                player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
                player.play()
            }
        case .off:
            break
        }
    }

    enum PlayerMode {
        case auto
        case manual
    }

    enum PlayLoopMode {
        case on
        case off
    }
}
