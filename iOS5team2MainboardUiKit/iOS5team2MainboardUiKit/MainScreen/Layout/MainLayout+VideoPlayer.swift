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

    // MARK: - Top Video Player Area

    /// # Overview
    /// 상단 영상 영역(플레이어 뷰)을 초기 구성합니다.
    ///
    /// # Discussion
    /// 이 영역은 전체 UI 중 가장 먼저 사용자 눈에 들어오는 주요 콘텐츠로,
    /// 다음 구성 요소를 포함합니다:
    /// - **영상 재생 뷰 (`playerView`)**
    /// - **전체 화면 버튼 (`fullScreenButton`)**
    /// - **현재 영상 클립 저장 버튼 (`saveToClipButton`)**
    ///
    /// 플레이어는 16:9 비율을 기반으로 하고,
    /// `.resizeAspectFill` 모드를 사용하여 화면을 꽉 채우되
    /// 좌우 또는 상하 일부가 잘릴 수 있는 형태로 구성됩니다.
    ///
    /// iPhone/세로 레이아웃과 iPad 가로 레이아웃을 별도 제약으로 관리합니다.
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

        // MARK: 기본(iPhone 세로 / iPad 세로)
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

        // MARK: iPad 가로 전용
        topVideoIPadLandscapeConstraints = [
            playerView.topAnchor.constraint(equalTo: languageButton.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),

            fullScreenButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -10),
            fullScreenButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10),

            saveToClipButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 10),
            saveToClipButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10)
        ]

        // 플레이어 영상 비율 설정
        playerView.playerLayer.videoGravity = .resizeAspectFill
        playerView.layer.masksToBounds = true
    }

    // MARK: - Progress Slider

    /// # Overview
    /// 영상의 재생 위치, 현재 시각, 총 길이를 표시하는 진행 UI를 구성합니다.
    ///
    /// # Discussion
    /// 이 영역은 다음을 포함합니다:
    /// - 현재 재생 시각(`start`)
    /// - 총 재생 시간(`end`)
    /// - 영상 위치 이동 슬라이더(`progressSlider`)
    ///
    /// 슬라이더는 드래그 및 탭 제스처를 통해 사용자가 원하는 지점으로 이동할 수 있습니다.
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

        // MARK: 기본 레이아웃
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

        // MARK: iPad 가로
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

        // Thumb 설정 (조작하기 쉬운 원형)
        let thumbCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: thumbCfg), for: .normal)

        progressSlider.thumbTintColor = AppColor.menuIcon
        progressSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)
    }

    // MARK: - Middle Video Buttons (재생/앞뒤 이동/볼륨/배속)

    /// # Overview
    /// 재생/일시정지, 되감기/앞으로, 볼륨, 배속 메뉴 버튼을 구성합니다.
    ///
    /// # Discussion
    /// - 중앙: 재생 관련 3개 버튼(되감기 / 재생 / 앞으로)
    /// - 좌측: 볼륨 버튼
    /// - 우측: 배속 메뉴 버튼 (DropDown 표시용)
    ///
    /// 구성 형태는 iPhone/세로와 iPad 가로에서 각각 다르게 제약 설정됩니다.
    func setVideoButton() {
        let playButtons: [UIButton] = [rewind15sButton, playButton, forward15sButton]

        volumeButton.setImage(UIImage(systemName: "speaker", withConfiguration: muteButtonCFG), for: .normal)
        volumeButton.tintColor = AppColor.menuIcon

        forward15sButton.setImage(
            UIImage(systemName: "10.arrow.trianglehead.clockwise", withConfiguration: forward15sButtonCFG),
            for: .normal
        )
        forward15sButton.tintColor = AppColor.menuIcon

        playButton.setImage(
            UIImage(systemName: "play.fill", withConfiguration: playButtonCFG),
            for: .normal
        )
        playButton.tintColor = AppColor.menuIcon

        rewind15sButton.setImage(
            UIImage(systemName: "10.arrow.trianglehead.clockwise", withConfiguration: rewind15sButtonCFG),
            for: .normal
        )
        rewind15sButton.tintColor = AppColor.menuIcon

        ellipsisButton.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: ellipsisButtonCFG),
            for: .normal
        )
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

        // MARK: 기본 레이아웃
        videoButtonDefaultConstraints = [
            volumeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            volumeButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            middleButtonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            ellipsisButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -22),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ]

        // MARK: iPad 가로 레이아웃
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

    // MARK: - Speed Menu

    /// # Overview
    /// 영상 배속 선택 드롭다운을 구성합니다.
    ///
    /// # Discussion
    /// 지원 배속: **1x, 1.25x, 1.5x, 2x**
    /// 선택 시 `onSpeedSelected` 콜백을 통해 선택값을 외부(MainViewController)로 전달합니다.
    ///
    /// iPad 가로 환경에서는 더 넓은 항목 표시를 위해
    /// 드롭다운의 width가 자동 조정됩니다.
    func configureVideoSpeed() {
        let speedList: [Double] = [1, 1.25, 1.5, 2]

        speedDropDown.dismissMode = .automatic
        speedDropDown.dataSource = speedList.map { value in
            value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        }

        speedDropDown.anchorView = ellipsisButton
        speedDropDown.textFont = .boldSystemFont(ofSize: 14)
        speedDropDown.direction = .bottom

        // DropDown 표시 직전 width/position 조정
        speedDropDown.willShowAction = { [weak self] in
            guard let self, self.ellipsisButton.window != nil else { return }
            self.ellipsisButton.layoutIfNeeded()

            let isIpadLandscape =
                self.traitCollection.userInterfaceIdiom == .pad &&
                self.bounds.width > self.bounds.height

            if isIpadLandscape {
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

    // MARK: - Volume Popup

    /// # Overview
    /// 볼륨 조절 팝업 UI를 구성합니다.
    ///
    /// # Discussion
    /// 구성 요소:
    /// - 세로 방향 볼륨 슬라이더 (`UISlider`)
    /// - 현재 볼륨 퍼센트 표시 라벨
    /// - 시스템 볼륨을 제어할 수 있는 숨겨진 `MPVolumeView`
    ///
    /// 슬라이더는 -.pi/2 회전하여 세로 형태로 표시되며
    /// 팝업은 기본적으로 숨김 상태(`isHidden = true`)입니다.
    func setVolumeSlider() {

        popup.backgroundColor = AppColor.background
        popup.layer.cornerRadius = 12
        popup.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        popup.layer.borderWidth = 1.5

        // 슬라이더 (세로)
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

        // MPVolumeView는 화면에 보이지 않도록 숨김 처리
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
