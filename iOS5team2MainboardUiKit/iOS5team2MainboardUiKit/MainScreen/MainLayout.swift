//
//  MainLayout.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/10/25.
//

import Foundation
import UIKit
import AVFoundation
import DropDown

class MainLayout: UIView {

    let start = UILabel()
    let end = UILabel()

    let languageImage = UIImage()

    let languageButton = UIButton()
    let searchButton = UIButton()
    let forward15sButton = UIButton()
    let playButton = UIButton()
    let rewind15sButton = UIButton()
    let airPlayButton = UIButton()
    let ellipsisButton = UIButton()
    let tagButton = UIButton()
    let clipButton = UIButton()
    let settingButton = UIButton()
    let bottomSearchButton = UIButton()

    let playerView = PlayerView()
    let middleButtonStackView = UIStackView()
    let bottomButtonStackView = UIStackView()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let bottomBarView = UIView()
    let dropView = UIView()
    let progressSlider = UISlider()

    let dropdown = DropDown()
    let itemList = ["Swift", "Kotlin", "PHP"]

    override func layoutSubviews() {
        super.layoutSubviews()
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width
            if flow.itemSize.width != width {
                flow.itemSize = CGSize(width: width, height: width * 0.68)
                flow.footerReferenceSize = CGSize(width: width, height: width * 0.08)
                flow.invalidateLayout()
            }
        }

        let anchor = languageButton
        dropdown.width = max(160, anchor.bounds.width)
        dropdown.direction = .bottom

        let cgX = max(0, anchor.bounds.width - max(160, anchor.bounds.width)) + 24
        dropdown.bottomOffset = CGPoint(x: cgX, y: anchor.bounds.height)
    }

    func setHeader() {
        addSubview(languageButton)
        addSubview(searchButton)

        languageButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            languageButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            languageButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: -10),
            languageButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            searchButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            searchButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])

        languageButton.setTitle("Swift", for: .normal)
        languageButton.setImage(UIImage(named: "Swift2")?.resized(to: .init(width: 34, height: 34)), for: .normal)
        languageButton.titleEdgeInsets.left = 10
        languageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        languageButton.setTitleColor(.main, for: .normal)
        languageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)

        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        searchButton.setImage(img, for: .normal)
        searchButton.tintColor = .main
        languageButton.showsMenuAsPrimaryAction = false
        languageButton.clipsToBounds = true
    }

    func configureLanguageMenu() {

        dropdown.dismissMode = .automatic
        dropdown.dataSource = itemList
        dropdown.anchorView = languageButton
        dropdown.textFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)

        dropdown.selectionAction = { [weak self] (index, item) in
            guard let self = self else { return }
            self.languageButton.setTitle(item, for: .normal)
            let name = self.itemList[index]
            self.languageButton.setImage(
                UIImage(named: name)?.resized(to: .init(width: 34, height: 34)),
                for: .normal
            )
        }

        updateDropdownColors(for: languageButton.traitCollection)
        dropdown.reloadAllComponents()

    }

    func updateDropdownColors(for trait: UITraitCollection) {

        let backgroundColor  = AppColor.background.resolvedColor(with: trait)
        let textColor = UIColor.main

        dropdown.backgroundColor = backgroundColor
        dropdown.textColor = textColor

    }

    func setTopVideo() {
        addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playerView.topAnchor
                .constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 70),
            playerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0/16.0)
        ])

        playerView.playerLayer.videoGravity = .resizeAspect

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
        NSLayoutConstraint.activate([
            progressSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressSlider.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 30),
            progressSlider.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            progressSlider.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            start.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            start.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            end.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            end.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15)

        ])

        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: cfg), for: .normal)

        progressSlider.thumbTintColor = AppColor.menuIcon
        progressSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)

    }

    func setVideoButton() {
        let playButtons: [UIButton] = [rewind15sButton, playButton, forward15sButton]

        let forward15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let rewind15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let airplayButtonCFG = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let ellipsisButtonCFG = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)

        airPlayButton.setImage(UIImage(systemName: "airplay.video",
                                       withConfiguration: airplayButtonCFG), for: .normal)
        airPlayButton.tintColor = AppColor.menuIcon

        forward15sButton.setImage(UIImage(systemName: "15.arrow.trianglehead.clockwise",
                                          withConfiguration: forward15sButtonCFG), for: .normal)
        forward15sButton.tintColor = AppColor.menuIcon

        playButton.setImage(UIImage(systemName: "play.fill",
                                    withConfiguration: playButtonCFG), for: .normal)
        playButton.tintColor = AppColor.menuIcon

        rewind15sButton.setImage(UIImage(systemName: "15.arrow.trianglehead.clockwise",
                                         withConfiguration: rewind15sButtonCFG), for: .normal)
        rewind15sButton.tintColor = AppColor.menuIcon

        ellipsisButton.setImage(UIImage(systemName: "ellipsis",
                                        withConfiguration: ellipsisButtonCFG), for: .normal)
        ellipsisButton.tintColor = AppColor.menuIcon

        addSubview(airPlayButton)
        addSubview(middleButtonStackView)
        addSubview(ellipsisButton)

        middleButtonStackView.axis = .horizontal
        middleButtonStackView.alignment = .fill
        middleButtonStackView.distribution = .fillEqually
        middleButtonStackView.spacing = 30

        playButtons.forEach { btn in
            middleButtonStackView.addArrangedSubview(btn)
        }

        middleButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        airPlayButton.translatesAutoresizingMaskIntoConstraints = false
        ellipsisButton.translatesAutoresizingMaskIntoConstraints = false

        middleButtonStackView.setContentHuggingPriority(.required, for: .horizontal)
        [forward15sButton, playButton, rewind15sButton].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        NSLayoutConstraint.activate([
            middleButtonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            middleButtonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            airPlayButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            airPlayButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),

            ellipsisButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ])
    }

    func setVideoCollection() {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColor.background
        collectionView.showsVerticalScrollIndicator = false
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: middleButtonStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        collectionView.layoutIfNeeded()
    }

    func setBottomMenu() {
        let bottomButtons: [UIButton] = [tagButton, clipButton, bottomSearchButton, settingButton]
        let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

        bottomButtonStackView.axis = .horizontal
        bottomButtonStackView.distribution = .fillEqually
        bottomButtonStackView.alignment = .center

        bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bottomBarView.isUserInteractionEnabled = false

        clipButton.setImage(UIImage(systemName: "paperclip",
                                    withConfiguration: cfg), for: .normal)
        tagButton.setImage(UIImage(systemName: "tag",
                                   withConfiguration: cfg), for: .normal)
        bottomSearchButton.setImage(UIImage(systemName: "magnifyingglass",
                                            withConfiguration: cfg), for: .normal)
        settingButton.setImage(UIImage(systemName: "gearshape",
                                       withConfiguration: cfg), for: .normal)

        bottomButtons.forEach { btn in
            btn.tintColor = AppColor.menuIcon
            btn.translatesAutoresizingMaskIntoConstraints = false
            bottomButtonStackView.addArrangedSubview(btn)
        }

        addSubview(bottomBarView)
        addSubview(bottomButtonStackView)

        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        bottomButtonStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            bottomBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 64),

            bottomButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15)
        ])
    }
}

#Preview {
    MainViewController()
}
