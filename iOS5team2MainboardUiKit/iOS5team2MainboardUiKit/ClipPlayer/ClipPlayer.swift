import UIKit
import SwiftUI
import AVKit
import AVFoundation
import CoreMedia

/// # Overview
/// 영상(클립)을 인라인으로 재생하는 싱글턴 플레이어입니다.
/// `AVPlayerViewController`를 내부에 가지고 있으며,
/// 재생/일시정지/클립 탐색/루프 재생 등의 기능을 제공합니다.
class ClipPlayer {
    var playerMode: PlayerMode = .auto       // 자동 재생 여부
    var playLoopMode: PlayLoopMode = .off    // 루프 재생 여부

    static let shared = ClipPlayer()         // 싱글톤

    private var playerViewControllerIfLoaded: AVPlayerViewController?

    private func loadPlayerViewControllerIfNeeded() {
        if playerViewControllerIfLoaded == nil {
            playerViewControllerIfLoaded = AVPlayerViewController()
        }
    }

    weak var delegate: ClipPlayerDelegate?

    /// 현재 재생할 영상 모델
    var video: VideoModel? {
        didSet {
            try? loadVideo()
        }
    }

    /// 현재 영상의 전체 재생 시간
    var durationTimeToEnd: CMTime?

    /// 현재 상태 집합 (OptionSet)
    private(set) var playerSetStates: States = [] {
        didSet {
            delegate?.clipPlayer(self, didChangeState: playerSetStates)
        }
    }

    // 내부 옵저버
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
    // 선택적 구현 지원
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint: CMTime) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, durationToplayToEnd: CMTime) {}
}

// MARK: - AVPlayerViewController 확장

extension AVPlayerViewController {
    /// 현재 재생 중인 영상이 특정 VideoModel과 동일한지 비교
    func hasSameContent(fromVideo video: VideoModel) -> Bool {
        guard let currentItemURLAsset = player?.currentItem?.asset as? AVURLAsset else {
            return false
        }
        return currentItemURLAsset.url == video.filePath
    }
}

// MARK: - 상태 정의

/// ClipPlayer의 상태를 나타내는 OptionSet
struct States: OptionSet {
    let rawValue: Int
    static let embeddedInline = States(rawValue: 1 << 0)
    static let videoLoaded = States(rawValue: 1 << 1)
    static let playing = States(rawValue: 1 << 2)
    static let paused = States(rawValue: 1 << 3)
}

// MARK: - 플레이어 뷰 삽입

extension ClipPlayer {
    /// 기존 부모에서 분리
    private func removeFromParentIfNeeded() {
        guard let vc = playerViewControllerIfLoaded else { return }
        if vc.parent != nil {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }

    /// AVPlayerViewController를 특정 UIView 내부에 임베드
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

// MARK: - 재생 시간 관찰

extension ClipPlayer {
    /// 일정 주기로 재생 시간을 콜백에 전달
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

// MARK: - 영상 로딩 및 재생

extension ClipPlayer {
    /// 새로운 영상 로드 및 재생 준비
    func loadVideo() throws {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.embeddedInline) else { return }
        guard let video else { return }

        if playerVC.hasSameContent(fromVideo: video) { return }

        let newVideo = AVPlayerItem(url: video.filePath)

        // 비동기로 영상 길이 추출
        Task {
            let duration = try await newVideo.asset.load(.duration)
            self.durationTimeToEnd = duration
            self.delegate?.clipPlayer(self, durationToPlayToEnd: duration)
        }

        // AVPlayer에 삽입
        if let player = playerVC.player {
            player.replaceCurrentItem(with: newVideo)
        } else {
            playerVC.player = AVPlayer(playerItem: newVideo)
        }

        // 상태 옵저버 연결
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

    /// 영상 재생 시작
    func startPlaying() {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.videoLoaded) else { return }

        playerVC.player?.play()
        playerSetStates.insert(.playing)
    }

    /// 영상 재생 일시정지
    func stopPlaying() {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.playing) else { return }

        playerVC.player?.pause()
        playerSetStates.insert(.paused)
    }

    /// 클립 단위 재생 (start~end)
    func playClip(_ clip: ClipModel) {
        guard
            let playerVC = playerViewControllerIfLoaded,
            playerSetStates.contains(.videoLoaded),
            let player = playerVC.player
        else { return }

        player.pause()

        let start = CMTime(seconds: clip.start, preferredTimescale: 600)
        let end = CMTime(seconds: clip.end, preferredTimescale: 600)

        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        // 언어 가중치: 재생 시간에 따라 분당 1점 추가
        if let lang = video?.tag {
            let duration = clip.end - clip.start
            let perMinuteScore = Int(duration / 60.0)
            if perMinuteScore > 0 {
                WeightStore.shared.add(perMinuteScore, to: lang)
            } else {
                WeightStore.shared.add(1, to: lang)
            }
        }

        // 기존 루프 제거
        if let token = loopObserver {
            player.removeTimeObserver(token)
            loopObserver = nil
        }

        // 루프 모드인 경우, 끝나면 자동 재시작
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

    // MARK: 모드 설정
    enum PlayerMode {
        case auto
        case manual
    }

    enum PlayLoopMode {
        case on
        case off
    }
}
