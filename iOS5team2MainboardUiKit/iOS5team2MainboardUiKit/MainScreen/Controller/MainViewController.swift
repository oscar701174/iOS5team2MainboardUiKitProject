import UIKit
import AVFoundation
import DropDown
import CoreData

class MainViewController: UIViewController {

    var isSearchButtonActive = true
    var player: AVPlayer?
    var timeObserver: Any?
    var didReachEnd = false
    var isScrubbing = false
    var wasPlayingBeforeScrub = false
    var wasPlayingBeforeFullScreen = false
    var isSearching = false

    var playingVideoURL: URL?
    let mainView = MainLayout()
    let playerManager = VideoPlayerManager()
    var videoList: [VideoEntity] = []
    var filteredVideos: [VideoEntity] = []

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VideoManager.seedIfNeeded()

        videoList = VideoManager.fetchVideos()

        videoList.sort { alpha, beta in
            let aIsSwift = (alpha.tag == "Swift")
            let bIsSwift = (beta.tag == "Swift")

            if aIsSwift != bIsSwift { return aIsSwift }
            return (alpha.title ?? "") < (beta.title ?? "")
        }

        mainView.onLanguageSelected = { [weak self] lang in
            guard let self else { return }
            self.prioritizeLanguage(lang)
        }

        bindPlayerCallbacks()

        if let player = playerManager.player {
            self.player = player
            mainView.playerView.player = player
        }

        mainView.setHeader()
        mainView.configureLanguageMenu()
        mainView.setTopVideo()
        mainView.setProgressSlider()
        mainView.setVideoButton()
        mainView.configureVideoSpeed()
        mainView.setVideoCollection()
        mainView.setBottomMenu()
        mainView.setSeachBar()

        mainView.collectionView.reloadData()

        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.searchBar.delegate = self

        mainView.searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        mainView.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        mainView.languageButton.addTarget(self, action: #selector(dropdownClick(_:)), for: .touchUpInside)
        mainView.fullScreenButton.addTarget(self, action: #selector(goFullScreen(_:)), for: .touchUpInside)
        mainView.forward15sButton.addTarget(self, action: #selector(forward15sButtonTapped(_:)), for: .touchUpInside)
        mainView.rewind15sButton.addTarget(self, action: #selector(rewind15sButtonTapped(_:)), for: .touchUpInside)
        mainView.bottomSearchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        mainView.ellipsisButton.addTarget(self, action: #selector(ellipsButtonClick(_:)), for: .touchUpInside)
        mainView.clipButton.addTarget(self, action: #selector(pushMyClipScreen(_:)), for: .touchUpInside)
        mainView.tagButton.addTarget(self, action: #selector(pushTagScreen(_:)), for: .touchUpInside)
        mainView.settingButton.addTarget(self, action: #selector(pushSettingScreen(_:)), for: .touchUpInside)
        mainView.progressSlider.addTarget(self, action: #selector(scrubBegan(_:)), for: .touchDown)
        mainView.progressSlider.addTarget(self, action: #selector(scrubChanged(_:)), for: .valueChanged)
        mainView.progressSlider.addTarget(self, action: #selector(scrubEnded(_:)), for: .touchUpInside)

        let sliderTapGesture =  UITapGestureRecognizer(target: self, action: #selector(progressSliderTapped(_:)))
        mainView.progressSlider.addGestureRecognizer(sliderTapGesture)

        mainView.onSpeedSelected = { [weak self] speed in
            guard let self else { return }
            self.playerManager.changeSpeed(to: speed)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            // 회전 후 실제 size 기준으로 iPad 가로/세로 판단
            self.mainView.updateForIpad(for: self.traitCollection,
                                        containerSize: size)
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.updateForIpad(for: traitCollection, containerSize: view.bounds.size)
    }

    func bindPlayerCallbacks() {

        playerManager.onPlayEnded = { [weak self] in
            self?.handlePlayEnd()
        }

        playerManager.onProgressChanged = { [weak self] progress, currentText in
            self?.mainView.progressSlider.value = progress
            self?.mainView.start.text = currentText
        }

        playerManager.onDurationLoaded = { [weak self] durationText in
            self?.mainView.end.text = durationText
        }

        playerManager.onPlayStateChanged = { [weak self] isPlaying in
            guard let self else { return }

            let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            let symbolName = isPlaying ? "pause.fill" : "play.fill"

            self.mainView.playButton.setImage(
                UIImage(systemName: symbolName, withConfiguration: cfg),
                for: .normal
            )
        }
    }

    func prioritizeLanguage(_ language: String) {

        // tag == lang 인 애들을 앞으로 몰기
        videoList.sort { lhs, rhs in
            let lhsMatch = (lhs.tag == language)
            let rhsMatch = (rhs.tag == language)

            // 둘 다 같은 상태(둘 다 맞거나 둘 다 아니거나)면 순서 변경 X
            if lhsMatch == rhsMatch { return false }

            // lhs가 선택한 언어면 앞으로
            return lhsMatch && !rhsMatch
        }

        mainView.collectionView.reloadData()
    }


    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.updateFooterView(for: traitCollection)
        mainView.langauageDropDown.reloadAllComponents()
        mainView.speedDropDown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }
}

#Preview(){
    UINavigationController(rootViewController: MainViewController())
}
