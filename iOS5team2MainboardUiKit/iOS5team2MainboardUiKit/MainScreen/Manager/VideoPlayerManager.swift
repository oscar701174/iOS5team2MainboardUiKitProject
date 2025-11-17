//
//  VideoPlayerManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import Foundation
import AVFoundation
import AVKit

/// # Overview
/// 단일 AVPlayer 인스턴스를 관리하는 재생 전용 매니저입니다.
///
/// # Discussion
/// 이 매니저는 ViewController 대신 다음 기능을 담당합니다:
/// - 영상 재생 시작 및 초기화
/// - 재생 시간 업데이트(슬라이더 반영)
/// - 끝까지 재생되었을 때 이벤트 처리
/// - 10초 앞으로/뒤로 이동
/// - 전체화면 전환 시 상태 유지
/// - 시스템 볼륨 모니터링 및 mute 동기화
///
/// `VideoPlayerManager`는 재생 관련 로직을 한 곳에 모아  
/// 메인 뷰컨트롤러가 UI 관리를 집중할 수 있도록 분리한 구조입니다.
class VideoPlayerManager: NSObject, AVPlayerViewControllerDelegate {

    // MARK: - Player & Observers

    /// # Overview
    /// 실제 영상을 재생하는 `AVPlayer` 인스턴스입니다.
    ///
    /// # Note
    /// 외부에서는 읽기만 가능하도록 `private(set)`으로 보호합니다.
    private(set) var player: AVPlayer?

    /// 재생 시간 업데이트용 타임 옵저버 토큰
    private var timeObserver: Any?

    /// 전체화면에서 돌아오기 전 재생 상태 저장용 플래그
    private var wasPlayingBeforeFullScreen = false

    /// 현재 표시 중인 전체화면 플레이어 VC (필요 시 참조)
    private weak var presentedPlayerVC: AVPlayerViewController?

    // MARK: - States

    /// 사용자가 슬라이더를 드래그하고 있는지 여부
    var isScrubbing = false

    /// 영상이 끝났는지 여부
    var didReachEnd = false

    /// 현재 시스템 볼륨
    var currentSystemVolume: Float = 1.0

    /// 시스템 볼륨 변화 감지용 옵저버
    var volumeObservation: NSKeyValueObservation?

    // MARK: - Callback Handlers

    /// 진행률(0~1), 현재 시각 문자열을 전달하는 콜백
    var onProgressChanged: ((Float, String) -> Void)?

    /// 전체 재생 길이 문자열을 전달하는 콜백
    var onDurationLoaded: ((String) -> Void)?

    /// 영상이 끝났을 때 한 번 호출되는 콜백
    var onPlayEnded: (() -> Void)?

    /// 재생/일시정지 상태가 변경될 때 호출되는 콜백
    var onPlayStateChanged: ((Bool) -> Void)?

    /// 볼륨 조절 UI에서 사용하는 시스템 볼륨 전달 콜백
    var onVolumeChanged: ((Float) -> Void)?

    // MARK: - Deinit

    deinit {
        /// 객체가 사라질 때 반드시 타임옵저버 삭제
        if let obs = timeObserver, let player {
            player.removeTimeObserver(obs)
        }
    }

    // MARK: - Playback Control

    /// # Overview
    /// 영상을 재생할 준비를 하고 AVPlayer를 초기화합니다.
    ///
    /// # Discussion
    /// - 기존 플레이어가 있었다면 옵저버를 먼저 제거합니다.  
    /// - 새로운 `AVPlayerItem`을 만들어 `AVPlayer`에 할당합니다.  
    /// - 진행 시간 업데이트, 재생 끝 이벤트, 시스템 볼륨 감지를 등록합니다.  
    ///
    /// - Parameters:
    ///   - url: 재생할 영상의 URL. 전달되지 않으면 기본 URL 사용.
    func startPlayback(with url: URL? = nil) {

        guard let defaultURL = URL(string: "https://example.com/default.mp4") else {
            return
        }

        let finalURL = url ?? defaultURL
        let playerItem = AVPlayerItem(url: finalURL)
        let player = AVPlayer(playerItem: playerItem)

        // 기존 타임옵저버 제거
        if let oldPlayer = self.player, let obs = timeObserver {
            oldPlayer.removeTimeObserver(obs)
            timeObserver = nil
        }

        self.player = player

        addProgressObserver()
        addPlayEndObserver()
        observeSystemVolume()

        // duration 로드 후 UI에 전달
        Task {
            do {
                let duration = try await playerItem.asset.load(.duration)
                let seconds = CMTimeGetSeconds(duration)

                if seconds.isFinite && seconds > 0 {
                    let text = TimeFormatter.timeFormat(seconds)
                    self.onDurationLoaded?(text)
                }
            } catch {
                print("Failed to load duration:", error)
            }
        }
    }

    /// # Overview
    /// 일정 간격마다 재생 위치를 가져오고(0.25초),  
    /// 슬라이더/시간 라벨 업데이트를 수행합니다.
    ///
    /// # Note
    /// 슬라이더 드래그 중(`isScrubbing == true`)에는 자동 업데이트를 중지합니다.
    func addProgressObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

        // 기존 옵저버 제거
        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self,
                  !self.isScrubbing,
                  let item = player.currentItem else { return }

            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else { return }

            let current = player.currentTime().seconds
            let progress = max(0, min(1, Float(current / duration)))

            self.onProgressChanged?(progress, TimeFormatter.timeFormat(current))
        }
    }

    /// # Overview
    /// 영상 재생이 끝났을 때 실행되는 Notification을 등록합니다.
    ///
    /// # Discussion
    /// AVPlayerItem이 끝 시점에 도달하면 App 쪽에 이벤트를 보내기 위한 용도입니다.
    func addPlayEndObserver() {
        guard let playerItem = player?.currentItem else { return }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.onPlayEnded?()
        }
    }

    /// # Overview
    /// 시스템 볼륨을 감시하여 UI 및 mute 상태를 동기화합니다.
    ///
    /// # Discussion
    /// AVAudioSession의 `outputVolume`을 KVO 방식으로 감지하여  
    /// 실제 시스템 볼륨과 앱의 UI가 서로 어긋나지 않도록 유지합니다.
    func observeSystemVolume() {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)

        volumeObservation = session.observe(\.outputVolume, options: [.new, .initial]) { [weak self] session, change in
            guard let self else { return }
            let volume = change.newValue ?? session.outputVolume
            self.currentSystemVolume = volume
            self.onVolumeChanged?(volume)
        }
    }

    /// # Overview
    /// 재생 시간을 기준으로 10초 앞으로 이동합니다.
    ///
    /// - Parameters:
    ///   - player: 이동시킬 AVPlayer 인스턴스
    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let total = CMTimeGetSeconds(duration)
        guard total.isFinite else { return }

        let current = player.currentTime().seconds
        let new = min(current + 10, total - 0.1)

        player.seek(to: CMTime(seconds: new, preferredTimescale: 600),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero)
    }

    /// # Overview
    /// 재생 시간을 기준으로 10초 뒤로 이동합니다.
    func skipRewindSeconds(player: AVPlayer) {
        let current = player.currentTime().seconds
        let new = max(current - 10, 0)

        player.seek(to: CMTime(seconds: new, preferredTimescale: 600),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero)
    }

    // MARK: - Fullscreen Handling

    /// # Overview
    /// 시스템 볼륨이 낮으면 player를 자동으로 mute 처리합니다.
    private func applyMuteAccordingToSystemVolume() {
        let systemVolume = AVAudioSession.sharedInstance().outputVolume
        let epsilon: Float = 0.001
        let shouldMute = systemVolume <= epsilon

        player?.isMuted = shouldMute
        presentedPlayerVC?.player?.isMuted = shouldMute
    }

    /// # Overview
    /// 영상을 전체화면 모드로 표시합니다.
    ///
    /// # Discussion
    /// - iOS 기본 전체화면 플레이어(AVPlayerViewController)를 사용합니다.  
    /// - PiP는 비활성화합니다.  
    /// - 재생이 끝나면 자동으로 전체화면에서 빠져나옵니다.
    ///
    /// - Parameters:
    ///   - viewController: 전체화면을 띄울 기준 ViewController
    ///   - player: 재생할 AVPlayer 인스턴스
    func presentFullScreenPlayer(from viewController: UIViewController, player: AVPlayer) {
        let pvc = AVPlayerViewController()

        pvc.player = player
        pvc.delegate = self
        pvc.showsPlaybackControls = true
        pvc.allowsPictureInPicturePlayback = false
        pvc.entersFullScreenWhenPlaybackBegins = false
        pvc.exitsFullScreenWhenPlaybackEnds = true
        pvc.modalPresentationStyle = .fullScreen

        player.allowsExternalPlayback = false

        viewController.present(pvc, animated: true) {
            player.play()
        }
    }

    /// 전체화면 진입 직전에 mute 상태를 정리합니다.
    func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
        applyMuteAccordingToSystemVolume()
    }

    /// 전체화면 종료 후 재생 상태 및 mute 상태를 복구합니다.
    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        let wasPlaying: Bool = {
            guard let player = playerViewController.player else { return false }
            return player.timeControlStatus == .playing || player.rate > 0
        }()

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self, let player = self.player else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let isMuted = (self.currentSystemVolume <= 0.001)
                self.player?.isMuted = isMuted
                self.presentedPlayerVC?.player?.isMuted = isMuted

                self.onVolumeChanged?(self.currentSystemVolume)

                if wasPlaying {
                    player.play()
                    self.onPlayStateChanged?(true)
                } else {
                    player.pause()
                    self.onPlayStateChanged?(false)
                }

                if playerViewController.presentingViewController == nil {
                    self.presentedPlayerVC = nil
                }
            }
        }
    }

    // MARK: - Speed

    /// # Overview
    /// 재생 속도를 변경합니다.
    ///
    /// - Parameters:
    ///   - rate: 적용할 배속 값 (예: 1.0, 1.5, 2.0)
    func changeSpeed(to rate: Double) {
        player?.rate = Float(rate)
    }
}

#Preview {
    MainViewController()
}
