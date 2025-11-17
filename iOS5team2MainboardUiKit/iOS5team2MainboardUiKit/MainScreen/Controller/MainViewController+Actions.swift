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

    @objc func playButtonTapped(_ sender: UIButton) {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if didReachEnd == true {
            didReachEnd = false
            playerManager.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        if mainView.playerView.player?.timeControlStatus == .paused {
            mainView.playButton.setImage(UIImage(systemName: "pause.fill",
                                                 withConfiguration: playButtonCFG), for: .normal)
            mainView.playerView.player?.play()
        } else if mainView.playerView.player?.timeControlStatus == .playing {
            mainView.playerView.player?.pause()
            mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                                 withConfiguration: playButtonCFG), for: .normal)
        }
    }

    @objc func forward15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }

        playerManager.skipForwardSeconds(player: player)
    }

    @objc func rewind15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.skipRewindSeconds(player: player)
    }

    @objc func handlePlayEnd() {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        guard let player = playerManager.player else { return }
        player.pause()
        didReachEnd = true
        mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                             withConfiguration: playButtonCFG), for: .normal)
        mainView.progressSlider.value = 1

        if let duration = player.currentItem?.duration.seconds, duration.isFinite {
            mainView.start.text = TimeFormatter.timeFormat(duration)
        }
    }

    @objc func dropdownClick(_ sender: UIButton) {
        mainView.langauageDropDown.show()
    }

    @objc func volumeButtonClick(_ sender: UIButton) {

        if mainView.popup.isHidden == true {
            mainView.popup.isHidden = false
        } else {
            mainView.popup.isHidden = true
        }

    }

    @objc func saveClipButtonClick(_ sender: UIButton) {

        print("[save] saveClipButtonClick tapped")
        print("[save] self:", self)

        guard let video = selectedVideo else {
            print("클립 저장 실패: 선택된 비디오가 없습니다.")
            return
        }

        // 저장 시도
        clipManager.saveToClip(video: video)
        print("클립 저장 요청 완료. 비디오 제목: \(video.title ?? "제목 없음")")

        // 저장 후 해당 비디오의 클립들을 다시 fetch해서 검증 로그 출력
        let clips = clipManager.fetchClips(for: video)
        print("현재 비디오의 클립 개수: \(clips.count)")
        // 필요하면 각 클립의 정보도 함께 출력
        for (idx, clip) in clips.enumerated() {
            let title = clip.title ?? "(제목 없음)"
            print(" - [\(idx)] title: \(title), start: \(clip.startSeconds), end: \(clip.endSeconds)")
        }
    }

    @objc func volumeChanged(_ sender: UISlider) {
        let percentage = Int(sender.value * 100)
        let volumeViewSlider = mainView.systemVolumeView.subviews.first { $0 is UISlider } as? UISlider

        volumeViewSlider?.value = sender.value
        mainView.volumeLabel.text = "\(percentage)"
    }

    @objc func ellipsButtonClick(_ sender: UIButton) {
        mainView.speedDropDown.show()
    }

    @objc func searchButtonTapped(_ sender: UIButton) {

        if isSearchButtonActive == true {
            showSearchBar()

        } else if isSearchButtonActive == false {
            hideSearchBar()
        }
    }

    @objc func pushMyClipScreen(_ sender: UIButton) {
        let settingVC = IntroPageViewController()
        if let nav = navigationController {
            nav.pushViewController(settingVC, animated: true)
        } else {
            present(UINavigationController(rootViewController: settingVC), animated: true)
        }
    }

    @objc func pushTagScreen(_ sender: UIButton) {
        let settingVC = IntroPageViewController()
        if let nav = navigationController {
            nav.pushViewController(settingVC, animated: true)
        } else {
            present(UINavigationController(rootViewController: settingVC), animated: true)
        }
    }

    @objc func pushSettingScreen(_ sender: UIButton) {
        let settingVC = SettingViewController()
        if let nav = navigationController {
            nav.pushViewController(settingVC, animated: true)
        } else {
            present(UINavigationController(rootViewController: settingVC), animated: true)
        }
    }

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

    @objc func scrubChanged(_ sender: UISlider) {

        guard let player = mainView.playerView.player?.currentItem else { return }

        let duration = player.duration.seconds

        guard duration.isFinite, duration > 0 else { return }

        let targetSeconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        mainView.start.text = TimeFormatter.timeFormat(targetSeconds)

        player.cancelPendingSeeks()

        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in }

    }

    @objc func scrubEnded(_ sender: UISlider) {
        guard let player = playerManager.player?.currentItem else { return }

        let duration = player.duration.seconds

        guard duration.isFinite, duration > 0 else { return }

        let targetSeconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self else {
                return
            }

            if self.wasPlayingBeforeScrub {
                self.playerManager.player?.play()
            }

            self.isScrubbing = false
        }
    }

    @objc func goFullScreen(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.presentFullScreenPlayer(from: self, player: player)
    }

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
            guard let self else { return }

            self.isScrubbing = false
        }
    }
}

#Preview() {
    MainViewController()
}
