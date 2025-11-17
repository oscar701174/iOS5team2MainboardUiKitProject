//
//  MainLayoutVideoPlayer.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import AVFoundation
import DropDown

extension MainLayout {

    // MARK: - Video Player (상단 영상 영역)

    /// # Overview
    /// 상단 영상 영역(플레이어 뷰)을 구성합니다.
    ///
    /// # Discussion
    /// 이 메서드는 다음 UI 요소를 배치합니다:
    /// - 영상 재생 화면(`playerView`)
    /// - 전체 화면 버튼(`fullScreenButton`)
    /// - 클립 저장 버튼(`saveToClipButton`)
    ///
    /// 기본(iPhone·iPad 세로) 레이아웃과  
    /// iPad 가로 전용 레이아웃을 각각 별도의 제약 배열로 관리합니다.
    ///
    /// 플레이어는 기본적으로 **16:9 비율**로 표시되며,
    /// 영상이 화면에 꽉 차게 보이도록 `resizeAspectFill` 모드를 사용합니다.
    func setTopVideo() {
        let img = UIImage(named: "FullScreen")?
            .resized(to: CGSize(width: 24, height: 24))
            .withRenderingMode(.alwaysTemplate)

        addSubview(playerView)
        addSubview(fullScreenButton)
        addSubview(saveToClipButton)

        playerView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        saveToClipButton.translatesAutoresizingMaskIntoConstraints = false

        fullScreenButton.setImage(img, for: .normal)
        fullScreenButton.tintColor = .white

        saveToClipButton.setImage(
            UIImage(systemName: "square.and.arrow.down", withConfiguration: cfg),
            for: .normal
        )
        saveToClipButton.tintColor = .white

        // 기본 레이아웃
        topVideoDefaultConstraints = [
            playerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerView.topAnchor.constraint(equalTo: topAnchor, constant: 110),
            playerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9/16),

            fullScreenButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -10),
            fullScreenButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10),

            saveToClipButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 5),
            saveToClipButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10)
        ]

        // iPad 가로 레이아웃
        topVideoIPadLandscapeConstraints = [
            playerView.topAnchor.constraint(equalTo: languageButton.bottomAnchor, constant: 0),
            playerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),

            fullScreenButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -10),
            fullScreenButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10),

            saveToClipButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 10),
            saveToClipButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10)
        ]

        playerView.playerLayer.videoGravity = .resizeAspectFill
        playerView.layer.masksToBounds = true
    }


    // MARK: - Progress Slider (진행 바 & 시간 표시)

    /// # Overview
    /// 영상 재생 진행도를 표시하는 슬라이더와  
    /// 시작/종료 시간을 구성합니다.
    ///
    /// # Discussion
    /// - `start` 라벨: 현재 재생 시각  
    /// - `end` 라벨: 총 재생 길이  
    /// - `progressSlider`: 드래그 및 탭으로 재생 위치 이동
    ///
    /// iPhone/세로 레이아웃과 iPad 가로 레이아웃을 분리하여 제약을 설정합니다.
    func setProgressSlider() {

        start.text = "00:00:00"
        end.text = "00:00:00"

        start.font = .systemFont(ofSize: 12, weight: .regular)
        end.font = .systemFont(ofSize: 12, weight: .regular)

        start.textColor = AppColor.menuIcon
        end.textColor = AppColor.menuIcon

        addSubview(progressSlider)
        addSubview(start)
        addSubview(end)

        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        start.translatesAutoresizingMaskIntoConstraints = false
        end.translatesAutoresizingMaskIntoConstraints = false

        // 기본 레이아웃
        progressSliderDefaultConstraints = [
            progressSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressSlider.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 10),
            progressSlider.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            progressSlider.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),

            start.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            start.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),

            end.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            end.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ]

        // iPad landscape 레이아웃
        progressSliderIPadLandscapeConstraints = [
            progressSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressSlider.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 10),
            progressSlider.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),

            start.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            start.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),

            end.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            end.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor)
        ]

        NSLayoutConstraint.activate(progressSliderDefaultConstraints)

        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: cfg), for: .normal)

        progressSlider.thumbTintColor = AppColor.menuIcon
        progressSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)
    }


    // MARK: - Video Buttons (재생 / 일시정지 / 10초 이동 / 볼륨 / 배속)

    /// # Overview
    /// 재생 관련 버튼(되감기·재생·앞으로 이동),  
    /// 볼륨 버튼, 배속 메뉴 버튼을 구성합니다.
    ///
    /// # Discussion
    /// 가운데는 재생 관련 버튼 3개가 `UIStackView`로 배치되며,  
    /// 좌측엔 볼륨, 우측엔 배속 메뉴 버튼이 위치합니다.
    ///
    /// iPhone/세로 / iPad 가로 레이아웃을 각각 분리하여 제약을 설정합니다.
    func setVideoButton() {
        let playButtons: [UIButton] = [rewind15sButton, playButton, forward15sButton]

        volumeButton.setImage(UIImage(systemName: "speaker", withConfiguration: muteButtonCFG), for: .normal)
        volumeButton.tintColor = AppColor.menuIcon

        forward15sButton.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise", withConfiguration: forward15sButtonCFG), for: .normal)
        forward15sButton.tintColor = AppColor.menuIcon

        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playButtonCFG), for: .normal)
        playButton.tintColor = AppColor.menuIcon

        rewind15sButton.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise", withConfiguration: rewind15sButtonCFG), for: .normal)
        rewind15sButton.tintColor = AppColor.menuIcon

        ellipsisButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: ellipsisButtonCFG), for: .normal)
        ellipsisButton.tintColor = AppColor.menuIcon

        addSubview(volumeButton)
        addSubview(middleButtonStackView)
        addSubview(ellipsisButton)

        middleButtonStackView.axis = .horizontal
        middleButtonStackView.alignment = .fill
        middleButtonStackView.distribution = .fillEqually
        middleButtonStackView.spacing = 30

        playButtons.forEach { middleButtonStackView.addArrangedSubview($0) }

        volumeButton.translatesAutoresizingMaskIntoConstraints = false
        middleButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        ellipsisButton.translatesAutoresizingMaskIntoConstraints = false

        videoButtonDefaultConstraints = [
            volumeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            volumeButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            middleButtonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            ellipsisButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -22),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ]

        videoButtonIPadLandscapeConstraints = [
            volumeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            volumeButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            middleButtonStackView.centerXAnchor.constraint(equalTo: progressSlider.centerXAnchor),
            middleButtonStackView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -50),

            ellipsisButton.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: -10),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15)
        ]
    }


    // MARK: - Speed Menu (배속 DropDown)

    /// # Overview
    /// 영상 배속 선택 메뉴를 구성합니다.
    ///
    /// # Discussion
    /// DropDown을 이용해 1x, 1.25x, 1.5x, 2x 중 하나를 선택할 수 있습니다.  
    /// 선택된 값은 `onSpeedSelected` 콜백을 통해 전달됩니다.
    ///
    /// iPad 가로 방향에서는 드롭다운 너비가 넓어지도록 조정합니다.
    func configureVideoSpeed() {
        let speedList: [Double] = [1, 1.25, 1.5, 2]

        speedDropDown.dismissMode = .automatic
        speedDropDown.dataSource = speedList.map { value in
            value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        }

        speedDropDown.anchorView = ellipsisButton
        speedDropDown.textFont = .boldSystemFont(ofSize: 14)
        speedDropDown.direction = .bottom

        // 표시 시 너비/위치 동적 조정
        speedDropDown.willShowAction = { [weak self] in
            guard let self, self.ellipsisButton.window != nil else { return }
            self.ellipsisButton.layoutIfNeeded()

            let isIPadLandscape =
                self.traitCollection.userInterfaceIdiom == .pad &&
                self.bounds.width > self.bounds.height

            if isIPadLandscape {
                self.speedDropDown.width = self.ellipsisButton.bounds.width * 1.5
                self.speedDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.ellipsisButton.bounds.height - 10
                )
            } else {
                let contentWidth = max(self.ellipsisButton.bounds.width * 1.5, 80)
                self.speedDropDown.width = min(contentWidth, self.bounds.width - 40)
                self.speedDropDown.bottomOffset = CGPoint(
                    x: 0,
                    y: self.ellipsisButton.bounds.height + 4
                )
            }
        }

        speedDropDown.selectionAction = { [weak self] index, _ in
            guard let self else { return }
            self.onSpeedSelected?(speedList[index])
        }

        updateDropdownColors(for: traitCollection)
        speedDropDown.reloadAllComponents()
    }


    // MARK: - Volume Popup (볼륨 슬라이더)

    /// # Overview
    /// 볼륨 조절 팝업 UI를 구성합니다.
    ///
    /// # Discussion
    /// - 세로 방향의 볼륨 슬라이더  
    /// - 현재 볼륨을 나타내는 숫자 라벨  
    /// - 시스템 볼륨과 연동되는 `MPVolumeView`
    ///
    /// 슬라이더는 -90° 회전시켜 세로 형태로 표시합니다.
    /// 팝업은 기본적으로 숨겨져 있으며, `volumeButtonClick()`에서 표시/숨김이 토글됩니다.
    func setVolumeSlider() {

        popup.backgroundColor = AppColor.background
        popup.layer.cornerRadius = 12
        popup.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        popup.layer.borderWidth = 1.5

        // 슬라이더 (세로 방향)
        volumeSlider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1

        volumeSlider.setThumbImage(
            UIImage(systemName: "square.fill", withConfiguration: cfg),
            for: .normal
        )

        volumeSlider.thumbTintColor = AppColor.menuIcon
        volumeSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)
        volumeSlider.minimumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)

        popup.addSubview(volumeSlider)
        popup.addSubview(volumeLabel)

        // 시스템 볼륨을 조절할 수 있는 기본 뷰(숨겨진 상태)
        systemVolumeView.frame = CGRect(x: -1000, y: -1000, width: 0, height: 0)
        systemVolumeView.alpha = 0.01
        addSubview(systemVolumeView)

        volumeLabel.textAlignment = .center
        volumeLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        volumeLabel.textColor = AppColor.textPrimary
        volumeLabel.text = "100"

        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        popup.translatesAutoresizingMaskIntoConstraints = false
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(popup)

        NSLayoutConstraint.activate([
            popup.widthAnchor.constraint(equalToConstant: 50),
            popup.heightAnchor.constraint(equalToConstant: 180),
            popup.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            popup.centerXAnchor.constraint(equalTo: volumeButton.centerXAnchor),
            popup.bottomAnchor.constraint(equalTo: volumeButton.topAnchor, constant: -5),

            volumeSlider.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
            volumeSlider.centerYAnchor.constraint(equalTo: popup.centerYAnchor, constant: -10),
            volumeSlider.heightAnchor.constraint(equalToConstant: 200),
            volumeSlider.widthAnchor.constraint(equalToConstant: 110),

            volumeLabel.topAnchor.constraint(equalTo: popup.bottomAnchor, constant: -35),
            volumeLabel.centerXAnchor.constraint(equalTo: popup.centerXAnchor)
        ])

        popup.isHidden = true
    }

}
