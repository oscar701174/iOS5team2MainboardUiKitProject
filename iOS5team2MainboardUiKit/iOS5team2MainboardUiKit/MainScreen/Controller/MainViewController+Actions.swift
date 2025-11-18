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
    /// 영상 재생과 일시정지를 전환합니다.
    ///
    /// # Discussion
    /// 재생 버튼을 누르면 현재 플레이어 상태에 따라
    /// 재생 또는 일시정지가 수행됩니다.
    /// 만약 영상이 끝까지 재생된 상태(`didReachEnd == true`)라면
    /// 시간을 처음으로 돌린 뒤 재생을 준비합니다.
    ///
    /// - Parameter sender: 재생/일시정지 버튼
    @objc func playButtonTapped(_ sender: UIButton) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if didReachEnd {
            didReachEnd = false
            playerManager.player?.seek(
                to: .zero,
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
        }

        guard let player = mainView.playerView.player else { return }

        switch player.timeControlStatus {
        case .paused:
            player.play()
            mainView.playButton.setImage(
                UIImage(systemName: "pause.fill", withConfiguration: cfg),
                for: .normal
            )
        case .playing:
            player.pause()
            mainView.playButton.setImage(
                UIImage(systemName: "play.fill", withConfiguration: cfg),
                for: .normal
            )
        default:
            break
        }
    }

    // MARK: - Skip Forward / Backward

    /// # Overview
    /// 영상을 15초 앞으로 이동합니다.
    ///
    /// # Discussion
    /// PlayerManager가 제공하는 기능을 호출하여
    /// 현재 재생 시간을 기준으로 15초 이동합니다.
    ///
    /// - Parameter sender: 앞으로 이동 버튼
    @objc func forward15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.skipForwardSeconds(player: player)
    }

    /// # Overview
    /// 영상을 15초 뒤로 이동합니다.
    ///
    /// # Discussion
    /// `skipRewindSeconds` 기능을 이용해
    /// 현재 재생 시간에서 15초 뒤로 이동합니다.
    ///
    /// - Parameter sender: 뒤로 이동 버튼
    @objc func rewind15sButtonTapped(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.skipRewindSeconds(player: player)
    }

    // MARK: - End of Playback

    /// # Overview
    /// 영상 재생이 끝났을 때 UI를 초기 상태로 되돌립니다.
    ///
    /// # Discussion
    /// - 재생 버튼을 ‘재생’ 아이콘으로 변경
    /// - 슬라이더를 마지막 위치로 이동
    /// - 종료된 시간을 라벨에 표시
    ///
    /// 재생이 끝난 이후 다시 재생 버튼을 누르면 처음부터 재생됩니다.
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
    /// 언어 선택 드롭다운을 표시합니다.
    @objc func dropdownClick(_ sender: UIButton) {
        mainView.langauageDropDown.show()
    }

    /// # Overview
    /// 볼륨 팝업의 표시/숨김 상태를 전환합니다.
    ///
    /// # Discussion
    /// 버튼을 누를 때마다 토글 방식으로 표시 여부가 변경됩니다.
    @objc func volumeButtonClick(_ sender: UIButton) {
        mainView.popup.isHidden.toggle()
    }

    // MARK: - Video Save (Export)

    /**
     # Overview
     현재 재생 중인 영상 파일을 사용자가 선택한 위치(파일 앱 폴더)에 저장(내보내기)하는 기능입니다.

     # Discussion
     - iOS의 `UIDocumentPickerViewController`의 `.exportToService` 모드를 사용하여
       사용자가 직접 저장할 폴더를 선택하도록 합니다.
     - 선택된 폴더에 영상 파일이 복사되며, 이미 동일한 파일명이 있을 경우 iOS가 자동 처리합니다.
     - CoreData의 클립 저장 기능과는 별도의 **영상 다운로드 기능**입니다.

     # Note
     - `playingVideoURL`이 반드시 실제 파일 URL이어야 합니다.
     - DocumentPicker는 버튼 텍스트가 “저장”으로 표시되기 때문에 유저 경험이 자연스럽습니다.
     */
    @objc func saveClipButtonClick(_ sender: UIButton) {
        guard let videoURL = playingVideoURL else {
            print("저장 실패: 현재 재생 중인 영상 URL 없음")
            return
        }

        // 영상 저장(Export) 모드로 DocumentPicker 실행
        let picker = UIDocumentPickerViewController(url: videoURL, in: .exportToService)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true)
    }



    // MARK: - Volume Slider

    /// # Overview
    /// 앱 내부 볼륨 슬라이더 값을 시스템 볼륨과 동기화합니다.
    ///
    /// - Parameter sender: 사용자에 의해 조작된 UISlider
    @objc func volumeChanged(_ sender: UISlider) {
        let percentage = Int(sender.value * 100)

        let systemSlider = mainView.systemVolumeView
            .subviews
            .first { $0 is UISlider } as? UISlider

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
    /// 검색 버튼이 눌릴 때마다
    /// `isSearchButtonActive` 값에 따라 열림/닫힘이 전환됩니다.
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
    /// NavigationController가 있으면 push,
    /// 없으면 navigation으로 감싸서 present 합니다.
    @objc func pushMyClipScreen(_ sender: UIButton) {
        let viewController = MyVideoListViewController()

        if let nav = navigationController {
            nav.pushViewController(viewController, animated: true)
        } else {
            present(UINavigationController(rootViewController: viewController), animated: true)
        }
    }

    /// # Overview
    /// 태그 화면으로 이동합니다.
    @objc func pushTagScreen(_ sender: UIButton) {
        let viewController = TagViewController()

        if let nav = navigationController {
            nav.pushViewController(viewController, animated: true)
        } else {
            present(UINavigationController(rootViewController: viewController), animated: true)
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

    // MARK: - Slider Scrubbing (Drag)

    /// # Overview
    /// 영상 재생 슬라이더 드래그가 시작될 때 호출됩니다.
    ///
    /// # Discussion
    /// 드래그 동안 재생을 멈추고,
    /// 드래그 종료 후 재생을 이어갈지 결정하기 위해
    /// 이전 재생 상태를 `wasPlayingBeforeScrub`에 저장합니다.
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
    /// 슬라이더 드래그 중에 영상 위치를 실시간으로 이동시킵니다.
    ///
    /// - Parameter sender: 이동 중인 슬라이더
    @objc func scrubChanged(_ sender: UISlider) {
        guard let item = mainView.playerView.player?.currentItem else { return }

        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }

        let seconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)

        mainView.start.text = TimeFormatter.timeFormat(seconds)
        item.cancelPendingSeeks()
        item.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// # Overview
    /// 슬라이더 드래그가 종료되면 최종 위치로 영상이 이동합니다.
    ///
    /// # Discussion
    /// 드래그 이전에 재생 중이었다면 재생을 이어서 진행합니다.
    ///
    /// - Parameter sender: 드래그를 마친 슬라이더
    @objc func scrubEnded(_ sender: UISlider) {
        guard let item = playerManager.player?.currentItem else { return }

        let duration = item.duration.seconds
        guard duration.isFinite, duration > 0 else { return }

        let seconds = Double(sender.value) * duration
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)

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
    /// 영상을 전체 화면으로 표시합니다.
    ///
    /// - Parameter sender: 전체 화면 버튼
    @objc func goFullScreen(_ sender: UIButton) {
        guard let player = playerManager.player else { return }
        playerManager.presentFullScreenPlayer(from: self, player: player)
    }

    // MARK: - Slider Tap

    /// # Overview
    /// 슬라이더를 탭한 위치로 즉시 이동합니다.
    ///
    /// # Discussion
    /// 드래그 없이도 ‘탭’만으로 재생 위치를 빠르게 이동할 수 있습니다.
    ///
    /// - Parameter gesture: 슬라이더 탭 제스처
    @objc func progressSliderTapped(_ gesture: UITapGestureRecognizer) {
        let slider = mainView.progressSlider
        let point = gesture.location(in: slider)

        isScrubbing = true

        let ratio = max(0, min(1, point.x / slider.bounds.width))
        let newValue = Float(ratio)
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

        let seconds = Double(newValue) * duration
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)

        mainView.start.text = TimeFormatter.timeFormat(seconds)

        item.cancelPendingSeeks()
        item.seek(
            to: targetTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        ) { [weak self] _ in
            self?.isScrubbing = false
        }
    }
}
