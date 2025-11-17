//
//  MainViewController+Actions.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit
import AVFoundation
import DropDown
import MediaPlayer

extension MainViewController {

    // MARK: - Play / Pause

    /// # Overview
    /// 영상의 재생과 일시정지를 전환합니다.
    ///
    /// # Discussion
    /// 사용자가 재생 버튼을 누르면 호출되며,
    /// 플레이어의 현재 상태에 따라 재생 또는 일시정지를 수행합니다.
    /// 재생이 끝난 상태(`didReachEnd == true`)에서는 항상
    /// 시간을 처음으로 돌려 초기 상태에서 재생을 준비합니다.
    ///
    /// - Parameters:
    ///   - sender: 재생/일시정지 버튼
    @objc func playButtonTapped(_ sender: UIButton) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if didReachEnd == true {
            didReachEnd = false
            playerManager.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        }

        if mainView.playerView.player?.timeControlStatus == .paused {
            mainView.playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: cfg), for: .normal)
            mainView.playerView.player?.play()
        } else if mainView.playerView.player?.timeControlStatus == .playing {
            mainView.playerView.player?.pause()
            mainView.playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: cfg), for: .normal)
        }
    }

    // MARK: - Skip Forward / Backward

    /// # Overview
    /// 영상을 15초 앞으로 이동합니다.
    ///
    /// # Discussion
    /// PlayerManager 내부의 `skipForwardSeconds` 기능을 호출하여
    /// 현재 재생 중인 영상의 시간을 15초 앞으로 이동시킵니다.
    ///
    /// - Parameters:
    ///   - sender: 앞으로 이동 버튼
    @objc func forward15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.skipForwardSeconds(player: player)
    }

    /// # Overview
    /// 영상을 15초 뒤로 이동합니다.
    ///
    /// # Discussion
    /// PlayerManager의 `skipRewindSeconds`를 통해
    /// 재생 시간을 15초 이전으로 이동시킵니다.
    ///
    /// - Parameters:
    ///   - sender: 뒤로 이동 버튼
    @objc func rewind15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.skipRewindSeconds(player: player)
    }

    // MARK: - End of Playback

    /// # Overview
    /// 영상 재생이 끝났을 때 플레이어 UI를 초기 상태로 돌립니다.
    ///
    /// # Discussion
    /// - 재생 버튼을 '재생' 상태로 설정합니다.
    /// - 슬라이더는 끝 위치로 이동합니다.
    /// - 재생된 전체 시간을 라벨에 표시합니다.
    @objc func handlePlayEnd() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        guard let player = playerManager.player else { return }

        player.pause()
        didReachEnd = true

        mainView.playButton.setImage(
            UIImage(systemName: "play.fill", withConfiguration: cfg),
            for: .normal
        )
        mainView.progressSlider.value = 1

        if let duration = player.currentItem?.duration.seconds, duration.isFinite {
            mainView.start.text = TimeFormatter.timeFormat(duration)
        }
    }

    // MARK: - Dropdown & Popup

    /// # Overview
    /// 언어 선택 드롭다운을 화면에 표시합니다.
    @objc func dropdownClick(_ sender: UIButton) {
        mainView.langauageDropDown.show()
    }

    /// # Overview
    /// 볼륨 팝업의 표시 상태를 전환합니다.
    ///
    /// # Discussion
    /// 한 번 누르면 표시, 다시 누르면 숨겨지는 방식으로 동작합니다.
    @objc func volumeButtonClick(_ sender: UIButton) {
        mainView.popup.isHidden.toggle()
    }

    // MARK: - Clip Save

    /// # Overview
    /// 현재 선택된 영상을 클립으로 저장합니다.
    ///
    /// # Discussion
    /// 선택된 `VideoEntity`가 존재하는 경우
    /// ClipManager를 통해 CoreData에 클립을 추가합니다.
    ///
    /// - Note:
    ///   선택된 영상이 없으면 저장이 실패합니다.
    @objc func saveClipButtonClick(_ sender: UIButton) {
        guard let video = selectedVideo else {
            print("클립 저장 실패: 선택된 비디오가 없습니다.")
            return
        }

        clipManager.saveToClip(video: video)

        let clips = clipManager.fetchClips(for: video)
        print("현재 비디오의 클립 개수:", clips.count)
    }

    // MARK: - Volume Slider

    /// # Overview
    /// 앱 내부의 볼륨 슬라이더 값을 시스템 볼륨과 동기화합니다.
    ///
    /// - Parameters:
    ///   - sender: 사용자 조작에 의해 변경된 UISlider
    @objc func volumeChanged(_ sender: UISlider) {
        let percentage = Int(sender.value * 100)

        let systemSlider = mainView.systemVolumeView.subviews.first { $0 is UISlider } as? UISlider
        systemSlider?.value = sender.value

        mainView.volumeLabel.text = "\(percentage)"
    }

    /// # Overview
    /// 배속 선택 드롭다운을 표시합니다.
    @objc func ellipsButtonClick(_ sender: UIButton) {
        mainView.speedDropDown.show()
    }

    // MARK: - Search Toggle

    /// # Overview
    /// 검색창을 표시하거나 숨깁니다.
    ///
    /// # Discussion
    /// `isSearchButtonActive` 상태에 따라
    /// 검색창을 열거나 닫는 동작을 수행합니다.
    @objc func searchButtonTapped(_ sender: UIButton) {
        if isSearchButtonActive {
            showSearchBar()
        } else {
            hideSearchBar()
        }
    }

    // MARK: - Navigation Push

    /// # Overview
    /// '내 클립' 화면으로 이동합니다.
    ///
    /// # Discussion
    /// 네비게이션 컨트롤러가 있으면 push 방식으로,
    /// 없으면 NavigationController로 감싼 후 present합니다.
    @objc func pushMyClipScreen(_ sender: UIButton) {
        let vc = IntroPageViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }

    /// # Overview
    /// 태그 화면으로 이동합니다.
    @objc func pushTagScreen(_ sender: UIButton) {
        let vc = IntroPageViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }

    /// # Overview
    /// 설정 화면으로 이동합니다.
    @objc func pushSettingScreen(_ sender: UIButton) {
        let vc = SettingViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }

    // MARK: - Slider Scrubbing

    /// # Overview
    /// 영상 재생 슬라이더를 드래그하기 시작할 때 호출됩니다.
    ///
    /// # Discussion
    /// 드래그 시작 전에 영상이 재생 중이었다면 일시정지하고,
    /// 드래그 종료 후 원래 재생 중이었는지 여부를 판단하기 위해
    /// **wasPlayingBeforeScrub** 상태를 기록합니다.
    @objc func scrubBegan(_ sender: UISlider) {
        isScrubbing = true
        guard let player = playerManager.player else { return }

        if player.timeControlStatus == .playing {
            wasPlayingBeforeScrub = true
            player.pause()
            player.currentItem?.cancelPendingSeeks()
        } else {
            wasPlayingBeforeScrub = false
        }
    }

    /// # Overview
    /// 드래그 중 실시간으로 영상 재생 위치를 이동합니다.
    ///
    /// - Parameters:
    ///   - sender: 조작 중인 슬라이더
    @objc func scrubChanged(_ sender: UISlider) {
        guard let item = mainView.playerView.player?.currentItem else { return }

        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }

        let targetSeconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        mainView.start.text = TimeFormatter.timeFormat(targetSeconds)

        item.cancelPendingSeeks()
        item.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// # Overview
    /// 슬라이더 드래그가 종료되면 최종 위치로 이동하고,
    /// 필요하면 재생도 다시 시작합니다.
    ///
    /// - Parameters:
    ///   - sender: 최종 값이 결정된 슬라이더
    @objc func scrubEnded(_ sender: UISlider) {
        guard let item = playerManager.player?.currentItem else { return }

        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }

        let targetSeconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        item.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self else { return }

            if self.wasPlayingBeforeScrub {
                self.playerManager.player?.play()
            }

            self.isScrubbing = false
        }
    }

    // MARK: - Full Screen

    /// # Overview
    /// 영상 플레이어를 전체 화면 모드로 표시합니다.
    ///
    /// - Parameters:
    ///   - sender: 전체 화면 버튼
    @objc func goFullScreen(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.presentFullScreenPlayer(from: self, player: player)
    }

    // MARK: - Slider Tap

    /// # Overview
    /// 슬라이더를 탭한 위치로 즉시 이동합니다.
    ///
    /// # Discussion
    /// 드래그 없이 ‘탭만’으로도 영상의 특정 위치로 이동할 수 있도록 합니다.
    ///
    /// - Parameters:
    ///   - gesture: 슬라이더 영역을 탭한 제스처
    @objc func progressSliderTapped(_ gesture: UITapGestureRecognizer) {
        let slider = mainView.progressSlider
        let point = gesture.location(in: slider)

        isScrubbing = true

        let ratio = max(0, min(1, point.x / slider.bounds.width))
        let newValue = slider.minimumValue + Float(ratio) * (slider.maximumValue - slider.minimumValue)
        slider.setValue(newValue, animated: false)

        guard let item = playerManager.player?.currentItem else {
            isScrubbing = false
            return
        }

        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else {
            isScrubbing = false
            return
        }

        let targetSeconds = Double(newValue) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        mainView.start.text = TimeFormatter.timeFormat(targetSeconds)

        item.cancelPendingSeeks()
        item.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.isScrubbing = false
        }
    }
}
