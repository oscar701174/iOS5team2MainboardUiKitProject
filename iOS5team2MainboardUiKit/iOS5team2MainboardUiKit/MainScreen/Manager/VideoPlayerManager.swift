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
/// 앱에서 사용되는 단일 AVPlayer를 관리하는 **전용 재생 매니저**입니다.
///
/// # Discussion
/// 이 매니저는 ViewController에서 재생 로직을 완전히 분리하여
/// 다음과 같은 기능을 독립적으로 처리합니다:
///
/// - AVPlayer 초기화 및 재생 제어
/// - 슬라이더/진행 시간 업데이트
/// - 영상 종료 감지 및 콜백 전송
/// - 10초 단위 이동(앞/뒤)
/// - 재생 속도 변경(배속)
/// - 전체화면 전환 시 배속/볼륨 상태 복원
/// - 시스템 볼륨(outputVolume) 감지 및 UI 동기화
///
/// 이로 인해 ViewController는 UI 처리에만 집중할 수 있으며,
/// 재생 관련 코드는 이 매니저에서 일관되게 관리됩니다.
class VideoPlayerManager: NSObject, AVPlayerViewControllerDelegate {

    // MARK: - Player & Observers

    /// # Overview
    /// 실제 영상을 재생하는 AVPlayer 인스턴스입니다.
    ///
    /// # Note
    /// 외부에서는 읽기만 가능하도록 `private(set)`으로 제한합니다.
    private(set) var player: AVPlayer?

    /// 주기적 시간 업데이트를 위한 옵저버 토큰입니다.
    private var timeObserver: Any?

    /// 전체화면 재생 시 사용되는 전용 플레이어 컨트롤러 참조입니다.
    private weak var presentedPlayerVC: AVPlayerViewController?

    // MARK: - States

    /// 사용자가 슬라이더를 조작 중인지 여부입니다.
    var isScrubbing = false

    /// 영상이 끝까지 재생되었는지 여부입니다.
    var didReachEnd = false

    /// 시스템 볼륨(outputVolume) 값입니다.
    var currentSystemVolume: Float = 1.0

    /// 현재 배속(rate) 값입니다.
    /// 전체화면 전환 시 유지하기 위해 별도로 저장합니다.
    var currentRate: Float = 1.0

    /// 시스템 볼륨을 감지하기 위한 KVO 옵저버입니다.
    var volumeObservation: NSKeyValueObservation?

    // MARK: - Callback Handlers
    /// 슬라이더 진행률(0~1)과 현재 시간 문자열을 전달합니다.
    var onProgressChanged: ((Float, String) -> Void)?

    /// 전체 영상 길이 문자열 전달
    var onDurationLoaded: ((String) -> Void)?

    /// 영상 종료 시 호출되는 이벤트
    var onPlayEnded: (() -> Void)?

    /// 재생/일시정지 상태 전달
    var onPlayStateChanged: ((Bool) -> Void)?

    /// 시스템 볼륨 변경 전달
    var onVolumeChanged: ((Float) -> Void)?

    // MARK: - Deinit

    /// # Overview
    /// 객체가 해제될 때 활성화된 타임옵저버를 정리합니다.
    deinit {
        if let obs = timeObserver, let player {
            player.removeTimeObserver(obs)
        }
    }

    // MARK: - Playback Control

    /// # Overview
    /// 새로운 영상을 재생할 준비를 하고 AVPlayer를 초기화합니다.
    ///
    /// # Discussion
    /// - 기존 AVPlayer에 등록된 옵저버 제거
    /// - 새 `AVPlayerItem` 생성 및 Player에 연결
    /// - 진행률 업데이트/종료 감지/시스템 볼륨 감시 설정
    /// - 영상 길이(duration) 비동기 로드 후 상단 UI 업데이트
    ///
    /// - Parameter url: 재생할 영상 URL. 값이 없으면 기본 URL을 사용합니다.
    func startPlayback(with url: URL? = nil) {
        guard let defaultURL = URL(string: "https://example.com/default.mp4") else { return }

        let finalURL = url ?? defaultURL
        let item = AVPlayerItem(url: finalURL)
        let player = AVPlayer(playerItem: item)

        // 기존 타임 옵저버 제거
        if let oldPlayer = self.player, let obs = timeObserver {
            oldPlayer.removeTimeObserver(obs)
            timeObserver = nil
        }

        self.player = player

        // 필수 옵저버 연결
        addProgressObserver()
        addPlayEndObserver()
        observeSystemVolume()

        // 영상 길이 로딩
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
    /// 일정 간격(0.25초)마다 현재 재생 위치를 감지하여 UI로 전달합니다.
    ///
    /// # Note
    /// - 슬라이더 드래그 중(`isScrubbing == true`)에는 업데이트를 멈춥니다.
    /// - duration이 유효할 때만 진행률을 계산합니다.
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
            let progress = Float(current / duration)

            self.onProgressChanged?(
                max(0, min(1, progress)),
                TimeFormatter.timeFormat(current)
            )
        }
    }

    /// # Overview
    /// 영상이 끝까지 재생되었을 때(Notification)를 감지하여 콜백으로 전달합니다.
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
    /// 시스템 볼륨(outputVolume)을 감시하여 UI와 동기화합니다.
    ///
    /// # Discussion
    /// KVO(Key-Value Observing)를 이용해 시스템 볼륨 값이 변경될 때마다
    /// `onVolumeChanged` 콜백을 실행합니다.
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

    // MARK: - Skip Controls

    /// # Overview
    /// 현재 재생 위치에서 10초 앞으로 이동합니다.
    ///
    /// # Note
    /// 영상의 총 길이를 넘지 않도록 최대값을 제한합니다.
    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let total = CMTimeGetSeconds(duration)
        guard total.isFinite else { return }

        let current = player.currentTime().seconds
        let new = min(current + 10, total - 0.1)

        player.seek(
            to: CMTime(seconds: new, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    /// # Overview
    /// 현재 재생 위치에서 10초 뒤로 이동합니다.
    ///
    /// # Note
    /// 0초 이전으로 내려가지 않도록 최소값을 제한합니다.
    func skipRewindSeconds(player: AVPlayer) {
        let current = player.currentTime().seconds
        let new = max(current - 10, 0)

        player.seek(
            to: CMTime(seconds: new, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    // MARK: - Fullscreen Handling

    /// # Overview
    /// AVPlayerViewController를 사용해 전체화면 플레이어를 표시합니다.
    ///
    /// # Discussion
    /// - PiP 비활성화
    /// - 전체화면 종료 시 자동 복귀
    /// - 현재 배속(currentRate) 유지
    ///
    /// 전체화면 이후 상태 복귀는 delegate에서 처리됩니다.
    func presentFullScreenPlayer(from viewController: UIViewController, player: AVPlayer) {
        let pvc = AVPlayerViewController()

        pvc.player = player
        pvc.delegate = self
        pvc.showsPlaybackControls = true
        pvc.allowsPictureInPicturePlayback = false
        pvc.entersFullScreenWhenPlaybackBegins = false
        pvc.exitsFullScreenWhenPlaybackEnds = true
        pvc.modalPresentationStyle = .fullScreen

        // AirPlay 등 외부 디바이스 재생 방지
        player.allowsExternalPlayback = false

        viewController.present(pvc, animated: true) {
            player.play()
        }
    }

    /// # Overview
    /// 전체화면이 시작될 때 현재 볼륨/배속을 적용합니다.
    func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
        playerViewController.player?.isMuted = (currentSystemVolume <= 0.001)

        if let player = playerViewController.player {
            player.rate = currentRate
        }
    }

    /// # Overview
    /// 전체화면을 종료한 후 재생 상태와 배속/볼륨을 복구합니다.
    ///
    /// # Discussion
    /// 전체화면 전환 과정에서 AVPlayer의 rate가 초기화될 수 있어
    /// 0.1초 지연 + 2단계 배속 복원 방식으로 안정적으로 복구합니다.
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

                // 전체화면 중 변경된 시스템 볼륨을 UI에 반영
                self.onVolumeChanged?(self.currentSystemVolume)

                if wasPlaying {
                    player.play()

                    // 1차 복원
                    player.rate = self.currentRate

                    // AVPlayer 내부 딜레이를 고려한 2차 복원
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
    /// 재생 속도(배속)를 변경하고 내부 상태로 저장합니다.
    ///
    /// # Parameters
    /// - rate: 1.0 / 1.25 / 1.5 / 2.0 등 적용할 배속 값
    func changeSpeed(to rate: Double) {
        currentRate = Float(rate)
        player?.rate = currentRate
    }
}
