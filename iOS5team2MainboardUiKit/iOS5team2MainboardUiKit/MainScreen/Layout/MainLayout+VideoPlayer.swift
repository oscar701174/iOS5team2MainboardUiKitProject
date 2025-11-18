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
    /// 상단 영상 재생 영역(Top Video Player)을 초기화하고 구성합니다.
    ///
    /// 이 영역은 전체 화면에서 가장 중요한 **메인 비디오 뷰(playerView)**를 포함하며,
    /// 사용자는 이 영역을 통해 영상 재생을 확인하고 전체 화면 전환 또는 클립 저장 기능을 사용할 수 있습니다.
    ///
    /// # Discussion
    /// 구성 요소:
    /// - `playerView`: 영상 플레이어 레이어를 포함한 커스텀 뷰
    /// - `fullScreenButton`: 전체 화면으로 전환하는 버튼
    /// - `saveToClipButton`: 현재 영상을 클립 목록에 저장하는 버튼
    ///
    /// 영상은 기본적으로 **16:9 비율**을 유지하며
    /// `.resizeAspectFill` 모드를 통해 화면을 꽉 채운 형태로 표시됩니다.
    ///
    /// iPhone/세로 레이아웃과 iPad/가로 레이아웃을 별도의 제약으로 관리합니다.
    ///
    /// > Note: 버튼 이미지 색상은 라이트/다크 모드 변화에 따라
    /// `updateButtonColors(for:)`에서 동적으로 조정됩니다.
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

        // Fullscreen button image
        fullScreenButton.setImage(img, for: .normal)

        // Save-to-clip button image
        let saveImg = UIImage(
            systemName: "square.and.arrow.down",
            withConfiguration: cfg
        )?.withRenderingMode(.alwaysTemplate)

        saveToClipButton.setImage(saveImg, for: .normal)

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

        // 플레이어 영상 비율 및 표시 방식 설정
        playerView.playerLayer.videoGravity = .resizeAspectFill
        playerView.layer.masksToBounds = true
    }

    /// # Overview
    /// 라이트/다크 모드에 따라 전체 화면 버튼 및 클립 저장 버튼의 색상을 업데이트합니다.
    ///
    /// # Discussion
    /// UIKit의 `UITraitCollection`을 기반으로 현재 테마(light/dark)를 판단하여
    /// 두 버튼의 `tintColor`를 동적으로 변경합니다.
    ///
    /// - Light Mode  → **검정색(.black)**
    /// - Dark Mode   → **흰색(.white)**
    ///
    /// 이 메서드는 `traitCollectionDidChange` 또는 레이아웃 초기화 시 호출됩니다.
    ///
    /// - Parameter trait: 현재 적용할 `UITraitCollection`
    func updateButtonColors(for trait: UITraitCollection) {
        let isLight = trait.userInterfaceStyle == .light
        let color: UIColor = isLight ? .black : .white

        fullScreenButton.tintColor = color
        saveToClipButton.tintColor = color
    }

    // MARK: - Progress Slider

    /// # Overview
    /// 영상 재생 진행도(시작 시간, 종료 시간, 진행 슬라이더)를 표시하는 UI를 구성합니다.
    ///
    /// # Discussion
    /// 구성 요소:
    /// - `start`: 현재 재생 시각(Label)
    /// - `end`: 총 영상 길이(Label)
    /// - `progressSlider`: 사용자 드래그 및 탭으로 이동 가능한 슬라이더
    ///
    /// 기본(iPhone/세로) 레이아웃과 iPad/가로 레이아웃을 각각 별도 제약으로 관리합니다.
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

        // 슬라이더 Thumb 설정
        let thumbCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        progressSlider.setThumbImage(
            UIImage(systemName: "circle.fill", withConfiguration: thumbCfg),
            for: .normal
        )

        progressSlider.thumbTintColor = AppColor.menuIcon
        progressSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)
    }

    // MARK: - Middle Video Buttons (재생/앞뒤 이동/볼륨/배속)

    /// # Overview
    /// 영상 재생과 조작을 위한 중앙 버튼 영역을 설정합니다.
    ///
    /// # Discussion
    /// 구성 요소:
    /// - 중앙(스택뷰):
    ///   되감기 15초, 재생/일시정지, 앞으로 15초
    /// - 좌측: 볼륨 버튼
    /// - 우측: 배속 설정 버튼(ellipsisButton - DropDown 표시)
    ///
    /// 버튼은 iPhone/세로 기준 기본 제약과
    /// iPad/가로 기준 별도 제약을 통해 구성됩니다.
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
            volumeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            volumeButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            middleButtonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            ellipsisButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -22),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ]

        // MARK: iPad 가로 레이아웃
        videoButtonIPadLandscapeConstraints = [
            volumeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 13),
            volumeButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            middleButtonStackView.centerXAnchor.constraint(equalTo: progressSlider.centerXAnchor),
            middleButtonStackView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -50),

            ellipsisButton.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: -10),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15)
        ]
    }

    // MARK: - Speed Menu (DropDown)

    /// # Overview
    /// 영상 배속을 설정하는 드롭다운 메뉴를 초기화합니다.
    ///
    /// # Discussion
    /// 선택 가능한 배속: **1.0x, 1.25x, 1.5x, 2.0x**
    /// 선택된 값은 `onSpeedSelected` 콜백을 통해 MainViewController로 전달됩니다.
    ///
    /// iPad 가로 환경에서는 메뉴 width를 넓게 설정하여 가독성을 확보합니다.
    ///
    /// - Important: DropDown은 UIKit 레이아웃 변화에 민감하므로
    ///   표시 직전(`willShowAction`)에 anchor 및 width 조정을 수행합니다.
    func configureVideoSpeed() {
        let speedList: [Double] = [1, 1.25, 1.5, 2]

        speedDropDown.dismissMode = .automatic
        speedDropDown.dataSource = speedList.map { value in
            value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        }

        speedDropDown.anchorView = ellipsisButton
        speedDropDown.textFont = .boldSystemFont(ofSize: 14)
        speedDropDown.direction = .bottom

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
    /// 볼륨 조절 팝업 UI를 초기화하고 구성합니다.
    ///
    /// # Discussion
    /// 구성 요소:
    /// - `volumeSlider`: 세로형 슬라이더(회전된 UISlider)
    /// - `systemVolumeView`: 시스템 볼륨을 제어하는 숨겨진 MPVolumeView
    /// - `volumeLabel`: 현재 볼륨 값(%) 표시
    /// - `popup`: 볼륨 조절 팝업 컨테이너
    ///
    /// 기본적으로 팝업은 숨겨진 상태(`isHidden = true`)이며
    /// 필요 시 볼륨 버튼 액션을 통해 표시/숨김이 전환됩니다.
    ///
    /// 슬라이더 thumb 및 색상은 AppColor.theme에 맞춰 구성됩니다.
    func setVolumeSlider() {

        popup.backgroundColor = AppColor.background
        popup.layer.cornerRadius = 12
        popup.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        popup.layer.borderWidth = 1.5

        // 세로 슬라이더
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

        // 시스템 볼륨 컨트롤(화면에 표시되지 않도록 위치 숨김)
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

#Preview() {
    MainViewController()
}
