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

        saveToClipButton.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: cfg), for: .normal)
        saveToClipButton.tintColor = .white

        topVideoDefaultConstraints = [
            playerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerView.topAnchor
                .constraint(equalTo: topAnchor, constant: 110),
            playerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9/16),

            fullScreenButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -10),
            fullScreenButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10),

            saveToClipButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 5),
            saveToClipButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10)
        ]

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

    func setProgressSlider() {

        start.text = "00:00:00"
        end.text = "00:00:00"

        start.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        end.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        start.textColor = AppColor.menuIcon
        end.textColor = AppColor.menuIcon

        addSubview(progressSlider)
        addSubview(start)
        addSubview(end)

        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        start.translatesAutoresizingMaskIntoConstraints = false
        end.translatesAutoresizingMaskIntoConstraints = false

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

    func setVideoButton() {
        let playButtons: [UIButton] = [rewind15sButton, playButton, forward15sButton]

        muteButton.setImage(UIImage(systemName: "speaker",
                                       withConfiguration: muteButtonCFG), for: .normal)
        muteButton.tintColor = AppColor.menuIcon

        forward15sButton.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise",
                                          withConfiguration: forward15sButtonCFG), for: .normal)
        forward15sButton.tintColor = AppColor.menuIcon

        playButton.setImage(UIImage(systemName: "play.fill",
                                    withConfiguration: playButtonCFG), for: .normal)
        playButton.tintColor = AppColor.menuIcon

        rewind15sButton.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise",
                                         withConfiguration: rewind15sButtonCFG), for: .normal)
        rewind15sButton.tintColor = AppColor.menuIcon

        ellipsisButton.setImage(UIImage(systemName: "ellipsis",
                                        withConfiguration: ellipsisButtonCFG), for: .normal)
        ellipsisButton.tintColor = AppColor.menuIcon

        addSubview(muteButton)
        addSubview(middleButtonStackView)
        addSubview(ellipsisButton)

        middleButtonStackView.axis = .horizontal
        middleButtonStackView.alignment = .fill
        middleButtonStackView.distribution = .fillEqually
        middleButtonStackView.spacing = 30

        playButtons.forEach { btn in
            middleButtonStackView.addArrangedSubview(btn)
        }
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        middleButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        ellipsisButton.translatesAutoresizingMaskIntoConstraints = false

        middleButtonStackView.setContentHuggingPriority(.required, for: .horizontal)
        [forward15sButton, playButton, rewind15sButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        videoButtonDefaultConstraints = [
            muteButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            muteButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            middleButtonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            ellipsisButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -22),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ]

        videoButtonIPadLandscapeConstraints = [
            muteButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            muteButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),

            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            middleButtonStackView.centerXAnchor.constraint(equalTo: progressSlider.centerXAnchor),
            middleButtonStackView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -50),

            ellipsisButton.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: -10),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15)
        ]
    }

    func configureVideoSpeed() {
        let speedList: [Double] = [1, 1.25, 1.5, 2]

        speedDropDown.dismissMode = .automatic
        speedDropDown.dataSource = speedList.map { value in
            value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
        }

        speedDropDown.anchorView = ellipsisButton
        speedDropDown.textFont = UIFont.boldSystemFont(ofSize: 14)
        speedDropDown.direction = .bottom

        speedDropDown.willShowAction = { [weak self] in
            guard let self, self.ellipsisButton.window != nil else { return }
            self.ellipsisButton.layoutIfNeeded()

            let isIPadLandscape = self.traitCollection.userInterfaceIdiom == .pad
            && self.bounds.width > self.bounds.height

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

        speedDropDown.selectionAction = { [weak self] (index, _) in
            guard let self = self else { return }
            let value = speedList[index]
            self.onSpeedSelected?(value)   // or delegate / notification
        }

        updateDropdownColors(for: traitCollection)
        speedDropDown.reloadAllComponents()
    }

    func setVolumeSlider() {

        popup.backgroundColor = AppColor.background
        popup.layer.cornerRadius = 12
        popup.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        popup.layer.borderWidth = 1.5

        volumeSlider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1

        volumeSlider.setThumbImage(UIImage(systemName: "square.fill", withConfiguration: cfg), for: .normal)

        volumeSlider.thumbTintColor = AppColor.menuIcon
        volumeSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)
        volumeSlider.minimumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)

        popup.addSubview(volumeSlider)
        popup.addSubview(volumeLabel)

        systemVolumeView.frame = CGRect(x: -1000, y: -1000, width: 0, height: 0)
        systemVolumeView.alpha = 0.01   // 거의 보이지 않음

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

               popup.centerXAnchor.constraint(equalTo: muteButton.centerXAnchor),
               popup.bottomAnchor.constraint(equalTo: muteButton.topAnchor, constant: -5),

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
