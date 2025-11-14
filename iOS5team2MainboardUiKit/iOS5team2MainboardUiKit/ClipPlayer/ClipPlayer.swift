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

protocol ClipPlayerDelegate: AnyObject {
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool)
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States)
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint: CMTime)
}

extension ClipPlayerDelegate {
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States) {}
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint: CMTime) {}
}

extension AVPlayerViewController {
    func hasSameContent(fromVideo video: VideoModel) -> Bool {
        guard let currentItemURLAsset = player?.currentItem?.asset as? AVURLAsset else {
            return false
        }
        return currentItemURLAsset.url == video.filePath
    }
}

struct States: OptionSet {
    
    let rawValue: Int
    static let embeddedInline = States(rawValue: 1 << 0)  // 앱 내 임베디드 재생 중
    static let videoLoaded = States(rawValue: 1 << 1)
    static let playing = States(rawValue: 1 << 2)// item changed
    static let paused = States(rawValue: 1 << 3)
}

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
// player time 관찰자
extension ClipPlayer {
    
    private func addTimeObserver() {
        guard let player = playerViewControllerIfLoaded?.player else { return }
        // 기존 observer 제거
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
//player 기능 구현
extension ClipPlayer {
    
    func loadVideo() throws {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.embeddedInline) else { return }
        guard let video else { return }
        if playerVC.hasSameContent(fromVideo: video) { return }

        let newVideo = AVPlayerItem(url: video.filePath)
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
                    //재생시간 observer setting
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
    
    func playClip(_ clip: ClipModel) {
        guard
            let playerVC = playerViewControllerIfLoaded,
            playerSetStates.contains(.videoLoaded),
            let player = playerVC.player
        else { return }

        // 기존 재생 중인 것 먼저 멈춤
        if let playerVC = playerViewControllerIfLoaded,
           let currentPlayer = playerVC.player {
            currentPlayer.pause()
        }

        let start = CMTime(seconds: clip.start, preferredTimescale: 600)
        let end   = CMTime(seconds: clip.end,   preferredTimescale: 600)

        // 정확한 위치로 이동
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        // 기존 loop observer 제거
        if let token = loopObserver {
            player.removeTimeObserver(token)
            loopObserver = nil
        }

        switch playLoopMode {
        case .on:
            loopObserver = player.addBoundaryTimeObserver(
                forTimes: [NSValue(time: end)],
                queue: .main
            ) { [weak self] in
                guard let _ = self else { return }
                player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
                player.play()
            }

        case .off:
            break
        }
    }
    
    func stopPlaying() {
        guard let playerVC = playerViewControllerIfLoaded else { return }
        guard playerSetStates.contains(.playing) else { return }
        playerVC.player?.pause()
        playerSetStates.insert(.paused)
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
