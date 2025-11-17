//
//  VideoPlayerManager.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import Foundation
import AVFoundation
import AVKit

/// 하나의 AVPlayer를 관리해 주는 클래스입니다.
/// - 영상 재생 시작
/// - 재생 위치(슬라이더) 업데이트
/// - 10초 앞으로 / 뒤로
/// - 배속 변경
/// - 전체화면 진입/종료 시 상태 유지
class VideoPlayerManager: NSObject, AVPlayerViewControllerDelegate {

    /// 실제 영상을 재생하는 플레이어
    /// 외부에서는 읽기만 가능
    private(set) var player: AVPlayer?

    /// 일정 간격으로 현재 재생 시간을 알려주는 토큰
    private var timeObserver: Any?

    /// (지금은 사용하지 않는 플래그 / 필요하면 쓸 수 있음)
    private var wasPlayingBeforeFullScreen = false

    /// 전체화면 플레이어(필요하면 나중에 사용)
    private weak var presentedPlayerVC: AVPlayerViewController?

    /// 슬라이더를 사용자가 드래그 중인지 여부
    var isScrubbing = false

    /// 재생이 끝났는지 여부
    var didReachEnd = false

    /// 진행률, 현재 시간 텍스트를 알려주는 콜백
    var onProgressChanged: ((Float, String) -> Void)?

    /// 전체 길이 텍스트를 알려주는 콜백
    var onDurationLoaded: ((String) -> Void)?

    /// 영상이 끝났을 때 알려주는 콜백
    var onPlayEnded: (() -> Void)?

    /// 재생 중/일시정지 상태가 바뀔 때 알려주는 콜백
    var onPlayStateChanged: ((Bool) -> Void)?

    var volumeObservation: NSKeyValueObservation?

    var currentSystemVolume: Float = 1.0

    var onVolumeChanged: ((Float) -> Void)?

    deinit {
        // 이 매니저가 사라질 때, 등록해 둔 옵저버 정리
        if let obs = timeObserver, let player {
            player.removeTimeObserver(obs)
        }
    }

    /// 영상을 재생할 준비를 합니다.
    /// - Parameter url: 재생할 영상 주소 (없으면 기본값 사용)
    func startPlayback(with url: URL? = nil) {

        // 기본으로 사용할 영상 주소
        guard let defaultURL = URL(string: "https://example.com/default.mp4") else {
            return
        }

        // url이 들어오면 그걸 쓰고, 아니면 defaultURL 사용
        let finalURL = url ?? defaultURL

        // 새 플레이어 아이템과 플레이어 생성
        let playerItem = AVPlayerItem(url: finalURL)
        let player = AVPlayer(playerItem: playerItem)

        // 이전에 쓰던 플레이어가 있다면, 그에 연결된 타임옵저버 제거
        if let oldPlayer = self.player, let obs = timeObserver {
            oldPlayer.removeTimeObserver(obs)
            timeObserver = nil
        }

        // 새 플레이어를 보관
        self.player = player

        // 슬라이더 업데이트용 옵저버 등록
        addProgressObserver()
        // 재생이 끝났는지 체크하는 옵저버 등록
        addPlayEndObserver()
        observeSystemVolume()

        // 전체 길이(duration)를 가져와서 텍스트로 전달
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

    /// 일정 시간마다 현재 재생 위치를 계산해서
    /// 슬라이더/레이블에 쓸 수 있게 콜백으로 넘겨줍니다.
    func addProgressObserver() {

        guard let player = player else { return }

        // 0.25초마다 콜백이 들어오도록 설정
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)

        // 기존 옵저버가 있으면 먼저 제거
        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        // 새 타임 옵저버 등록
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self else { return }

            // 사용자가 슬라이더를 드래그 중이면, 자동 업데이트는 잠시 중지
            guard !self.isScrubbing, let item = player.currentItem else {
                return
            }

            let duration = item.duration.seconds
            // 전체 길이가 제대로 들어있을 때만 진행률 계산
            guard duration.isFinite, duration > 0 else { return }

            let current = player.currentTime().seconds
            let progress = max(0, min(1, Float(current / duration)))
            let currentText = TimeFormatter.timeFormat(current)

            // 화면 쪽으로 진행률과 현재 시간 텍스트 전달
            self.onProgressChanged?(progress, currentText)
        }
    }

    /// 영상이 끝났을 때 한 번 호출되는 알림을 등록합니다.
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

    func observeSystemVolume() {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)

        volumeObservation = session.observe(\.outputVolume, options: [.new, .initial]) { [weak self] session, change in
            guard let self else { return }
            let volume = change.newValue ?? session.outputVolume
            self.currentSystemVolume = volume

            // MainViewController로 전달
            self.onVolumeChanged?(volume)
        }
    }

    /// 10초 앞으로 이동합니다.
    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        guard durationSeconds.isFinite else { return }

        let currentTime = player.currentTime().seconds
        // 끝을 살짝 넘지 않도록 duration - 0.1까지로 제한
        let newTime = min(currentTime + 10, durationSeconds - 0.1)
        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)

        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// 10초 뒤로 이동합니다.
    func skipRewindSeconds(player: AVPlayer) {
        let currentTime = player.currentTime().seconds
        // 0초보다 아래로 내려가지 않도록 제한
        let newTime = max(currentTime - 10, 0)
        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)

        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// 시스템 볼륨이 0이면 player를 음소거합니다.
    /// (하드웨어 볼륨 버튼 상태에 맞추고 싶을 때 사용)
    private func applyMuteAccordingToSystemVolume() {
        let audioSession = AVAudioSession.sharedInstance()
        let systemVolume = audioSession.outputVolume

        // 0과 완전 똑같이 비교하기 애매하니, 아주 작은 값(epsilon) 사용
        let epsilon: Float = 0.001
        let shouldMute = systemVolume <= epsilon

        player?.isMuted = shouldMute
        presentedPlayerVC?.player?.isMuted = shouldMute
    }

    /// AVPlayerViewController를 전체화면으로 띄웁니다.
    func presentFullScreenPlayer(from viewController: UIViewController, player: AVPlayer) {
        let pvc = AVPlayerViewController()

        pvc.player = player
        pvc.delegate = self

        // 아래쪽 기본 컨트롤(재생 버튼, 슬라이더 등)을 보이게 할지 여부
        pvc.showsPlaybackControls = true

        // PiP(작은 창) 기능은 사용하지 않음
        pvc.allowsPictureInPicturePlayback = false

        // 재생 시작한다고 자동으로 전체화면으로 가지는 않도록
        pvc.entersFullScreenWhenPlaybackBegins = false

        // 재생이 끝나면 전체화면에서 빠져나오게 설정
        pvc.exitsFullScreenWhenPlaybackEnds = true

        // 모달을 전체화면 스타일로 표시
        pvc.modalPresentationStyle = .fullScreen

        // AirPlay 등 외부 기기로 보내지 못하게 막고 싶을 때 사용
        player.allowsExternalPlayback = false

        viewController.present(pvc, animated: true) {
            // 전체화면 진입 후 재생 시작
            player.play()
        }
    }

    // MARK: - AVPlayerViewControllerDelegate

    /// 전체화면으로 들어가기 직전에 한 번 호출됩니다.
    func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
        // 시스템 볼륨이 0이면 player를 mute로 맞춰줌
        applyMuteAccordingToSystemVolume()
    }

    /// 전체화면에서 빠져나올 때 호출됩니다.
    /// (재생 중이던 상태를 이어주는 역할)
    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        // 전체화면에서 재생 중이었는지 확인
        let wasPlaying: Bool
        if let player = playerViewController.player {
            wasPlaying = (player.timeControlStatus == .playing || player.rate > 0)
        } else {
            wasPlaying = false
        }

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self, let player = self.player else { return }

            // *** 핵심 포인트 ***
            // 애니메이션 끝나고 약간 딜레이 준 뒤에 볼륨/뮤트/UI 업데이트
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                // 시스템 볼륨 기반으로 mute 상태 정리
                let isMuted = (self.currentSystemVolume <= 0.001)
                self.player?.isMuted = isMuted
                self.presentedPlayerVC?.player?.isMuted = isMuted

                // MainViewController 쪽에게 현재 볼륨 전달
                self.onVolumeChanged?(self.currentSystemVolume)

                // 재생 상태 복구
                if wasPlaying {
                    player.play()
                    self.onPlayStateChanged?(true)
                } else {
                    player.pause()
                    self.onPlayStateChanged?(false)
                }

                // 전체화면 VC 참조 제거
                if playerViewController.presentingViewController == nil {
                    self.presentedPlayerVC = nil
                }
            }
        }
    }

    /// 재생 속도(배속)를 바꿉니다. 예: 0.5, 1.0, 1.5, 2.0
    func changeSpeed(to rate: Double) {
        player?.rate = Float(rate)
    }

}

#Preview {
    MainViewController()
}
