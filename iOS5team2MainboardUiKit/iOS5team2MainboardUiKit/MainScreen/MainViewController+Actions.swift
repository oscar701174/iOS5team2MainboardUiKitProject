//
//  MainViewController+Actions.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit
import AVFoundation
import DropDown

extension MainViewController {

    @objc func playButtonTapped(_ sender: UIButton) {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if didReachEnd == true {
            didReachEnd = false
            player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
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
        guard let player else {
            return
        }
        skipForwardSeconds(player: player)
    }

    @objc func rewind15sButtonTapped(_ sender: UIButton) {
        guard let player else {
            return
        }
        skipRewindSeconds(player: player)
    }

    @objc func dropdownClick(_ sender: UIButton) {
        mainView.dropdown.show()
    }

    @objc func searchButtonTapped(_ sender: UIButton) {

        if isSearchButtonActive == true {
            showSearchBar()

        } else if isSearchButtonActive == false {
            hideSearchBar()
        }
    }

    @objc func handlePlayEnd() {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        player?.pause()
        didReachEnd = true
        mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                             withConfiguration: playButtonCFG), for: .normal)
        mainView.progressSlider.value = 1

        if let duration = player?.currentItem?.duration.seconds, duration.isFinite {
            mainView.start.text = TimeFormatter.timeFormat(duration)
        }
    }

    @objc func pushMyClipScreen(_ sender: UIButton) {
        let temp = UIViewController()
        temp.view.backgroundColor = AppColor.background
        navigationController?.pushViewController(temp, animated: true)
    }

    @objc func pushTagScreen(_ sender: UIButton) {
        let temp = UIViewController()
        temp.view.backgroundColor = AppColor.background
        navigationController?.pushViewController(temp, animated: true)
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

        guard let player = mainView.playerView.player else { return }

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
        guard let player = mainView.playerView.player?.currentItem else { return }

        let duration = player.duration.seconds

        guard duration.isFinite, duration > 0 else { return }

        let targetSeconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self else {
                return
            }

            if self.wasPlayingBeforeScrub {
                self.player?.play()
            }

            self.isScrubbing = false
        }
    }

    @objc func goFullScreen(_ sender: UIButton) {
        guard let player else {
            return
        }

        presentFullScreenPlayer(from: self, player: player)
    }
}
