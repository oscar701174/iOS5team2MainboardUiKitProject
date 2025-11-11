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
        let temp = UIViewController()
        temp.view.backgroundColor = AppColor.background
        navigationController?.pushViewController(temp, animated: true)
    }

}
