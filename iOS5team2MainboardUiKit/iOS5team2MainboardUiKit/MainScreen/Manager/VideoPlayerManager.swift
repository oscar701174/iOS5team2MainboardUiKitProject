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
/// 단일 `AVPlayer` 인스턴스를 관리하는 재생 전용 매니저입니다.
///
/// # Discussion
/// 이 매니저는 ViewController 대신 다음과 같은 역할을 수행합니다:
/// - 영상 재생 초기화 및 상태 관리
/// - 슬라이더/타임라벨 업데이트
/// - 영상 종료 감지
/// - 10초 앞으로/뒤로 이동
/// - 배속(speed) 변경 및 유지
/// - 전체화면 전환 시 재생 상태/배속/볼륨 동기화
///
/// 재생 관련 로직을 ViewController에서 분리하여
/// UI 코드와 재생 로직이 섞이지 않도록 구성한 구조입니다.
class VideoPlayerManager: NSObject, AVPlayerViewControllerDelegate {

    // MARK: - Player & Observers

    /// # Overview
    /// 실제 영상을 재생하는 AVPlayer 인스턴스입니다.
    /// 읽기 전용으로 외부에 노출됩니다.
    private(set) var player: AVPlayer?

    /// 타임 업데이트용 옵저버 토큰
    private var timeObserver: Any?

    /// 전체화면 진입/복귀 시 필요한 참조
    private weak var presentedPlayerVC: AVPlayerViewController?

    // MARK: - States

    /// 슬라이더 조작 여부
    var isScrubbing = false

    /// 영상 종료 여부
    var didReachEnd = false

    /// 시스템 볼륨 값
    var currentSystemVolume: Float = 1.0

    /// 현재 배속 값 (전체화면 전환 시 유지하기 위해 사용)
    var currentRate: Float = 1.0

    /// 시스템 볼륨 KVO 옵저버
    var volumeObservation: NSKeyValueObservation?

    // MARK: - Callback Handlers

    /// 진행률(0~1)과 현재 재생 시간 문자열을 전달
    var onProgressChanged: ((Float, String) -> Void)?

    /// 전체 영상 길이 문자열 전달
    var onDurationLoaded: ((String) -> Void)?

    /// 영상 끝남 이벤트 전달
    var onPlayEnded: (() -> Void)?

    /// 재생/일시정지 상태 전달
    var onPlayStateChanged: ((Bool) -> Void)?

    /// 시스템 볼륨값 전달
    var onVolumeChanged: ((Float) -> Void)?

    // MARK: - Deinit

    deinit {
        if let obs = timeObserver, let player {
            player.removeTimeObserver(obs)
        }
    }

    // MARK: - Playback Control

    /// # Overview
    /// 영상을 재생할 준비를 하고 AVPlayer를 초기화합니다.
    ///
    /// # Discussion
    /// - 기존 플레이어에 등록된 옵저버는 먼저 제거합니다.
    /// - 새로운 AVPlayerItem을 생성하고 Player에 연결합니다.
    /// - 진행률 업데이트, 영상 종료, 시스템 볼륨 감지 등을 설정합니다.
    ///
    /// - Parameter url: 재생할 영상 URL. 없으면 기본 테스트용 URL 사용.
    func startPlayback(with url: URL? = nil) {
        guard let defaultURL = URL(string: "https://example.com/default.mp4") else { return }

        let finalURL = url ?? defaultURL
        let item = AVPlayerItem(url: finalURL)
        let player = AVPlayer(playerItem: item)

        if let oldPlayer = self.player, let obs = timeObserver {
            oldPlayer.removeTimeObserver(obs)
            timeObserver = nil
        }

        self.player = player

        addProgressObserver()
        addPlayEndObserver()
        observeSystemVolume()

        Task {
            do {
                let duration = try await item.asset.load(.duration)
                let seconds = CMTimeGetSeconds(duration)
                if seconds.isFinite && seconds > 0 {
                    self.onDurationLoaded?(TimeFormatter.timeFormat(seconds))
                }
            } catch {
                print("Failed to load duration:", error)
            }
        }
    }

    /// # Overview
    /// 일정 간격(0.25초)마다 현재 재생 위치를 받아 UI로 전달합니다.
    ///
    /// # Note
    /// 슬라이더 조작 중에는 자동 업데이트를 멈춥니다.
    func addProgressObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

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
            let progress = Float(current / duration)

            self.onProgressChanged?(max(0, min(1, progress)),
                                   TimeFormatter.timeFormat(current))
        }
    }

    /// # Overview
    /// 영상 종료 시 알림(Notification)을 받아 콜백으로 전달합니다.
    func addPlayEndObserver() {
        guard let item = player?.currentItem else { return }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.onPlayEnded?()
        }
    }

    /// # Overview
    /// 시스템 볼륨(outputVolume)을 감지하여 UI와 동기화합니다.
    func observeSystemVolume() {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)

        volumeObservation = session.observe(\.outputVolume, options: [.new, .initial]) { [weak self] _, change in
            guard let self else { return }
            let volume = change.newValue ?? session.outputVolume
            self.currentSystemVolume = volume
            self.onVolumeChanged?(volume)
        }
    }

    // MARK: - Skip

    /// # Overview
    /// 현재 위치에서 10초 앞으로 이동합니다.
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
    /// 현재 위치에서 10초 뒤로 이동합니다.
    func skipRewindSeconds(player: AVPlayer) {
        let current = player.currentTime().seconds
        let new = max(current - 10, 0)

        player.seek(to: CMTime(seconds: new, preferredTimescale: 600),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero)
    }

    // MARK: - Fullscreen Handling

    /// # Overview
    /// AVPlayerViewController를 이용해 전체화면 재생을 시작합니다.
    ///
    /// # Discussion
    /// - PiP 비활성화
    /// - 전체화면 종료 시 자동 복귀
    /// - 전체화면 진입 시 현재 배속 유지
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

    /// # Overview
    /// 전체화면 진입 직후 현재 배속을 적용합니다.
    func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
        playerViewController.player?.isMuted = (currentSystemVolume <= 0.001)

        if let player = playerViewController.player {
            player.rate = currentRate
        }
    }

    /// # Overview
    /// 전체화면 종료 후 재생 상태와 볼륨/배속 정보를 복구합니다.
    ///
    /// # Discussion
    /// - 전체화면 전환 중 AVPlayer의 내부 상태가 1.0으로 초기화될 수 있어
    ///   약간의 지연 후 배속을 두 번 적용해 안정적으로 복구합니다.
    func playerViewController(
        _ pvc: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        let wasPlaying: Bool = {
            guard let player = pvc.player else { return false }
            return player.timeControlStatus == .playing || player.rate > 0
        }()

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self, let player = self.player else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                self.onVolumeChanged?(self.currentSystemVolume)

                if wasPlaying {
                    player.play()

                    // 1차 배속 복원
                    player.rate = self.currentRate

                    // 2차 배속 복원 (AVPlayer 내부 리셋 방지용)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        player.rate = self.currentRate
                    }

                    self.onPlayStateChanged?(true)
                } else {
                    player.pause()
                    self.onPlayStateChanged?(false)
                }
            }
        }
    }

    // MARK: - Speed

    /// # Overview
    /// 재생 속도를 변경하고 내부 상태에 저장합니다.
    ///
    /// # Parameters
    /// - rate: 1.0, 1.25, 1.5, 2.0 등 적용할 배속 값
    func changeSpeed(to rate: Double) {
        currentRate = Float(rate)
        player?.rate = currentRate
    }
}
