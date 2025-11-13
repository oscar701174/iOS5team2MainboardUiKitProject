import UIKit
import AVFoundation
import DropDown

class MainViewController: UIViewController {

    var isSearchButtonActive = true

    var player: AVPlayer?
    var timeObserver: Any?

    var didReachEnd = false
    var isScrubbing = false
    var wasPlayingBeforeScrub = false
    var wasPlayingBeforeFullScreen = false

    var playingVideoURL: URL?
    let mainView = MainLayout()
    let playerManager = VideoPlayerManager()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindPlayerCallbacks()

        playerManager.startPlayback()

        if let player = playerManager.player {
            self.player = player
            mainView.playerView.player = player
        }

        mainView.setHeader()
        mainView.configureLanguageMenu()
        mainView.setTopVideo()
        mainView.setProgressSlider()
        mainView.setVideoButton()
        mainView.setVideoCollection()
        mainView.setBottomMenu()
        mainView.setSeachBar()

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
        mainView.clipButton.addTarget(self, action: #selector(pushMyClipScreen(_:)), for: .touchUpInside)
        mainView.tagButton.addTarget(self, action: #selector(pushTagScreen(_:)), for: .touchUpInside)
        mainView.settingButton.addTarget(self, action: #selector(pushSettingScreen(_:)), for: .touchUpInside)
        mainView.progressSlider.addTarget(self, action: #selector(scrubBegan(_:)), for: .touchDown)
        mainView.progressSlider.addTarget(self, action: #selector(scrubChanged(_:)), for: .valueChanged)
        mainView.progressSlider.addTarget(self, action: #selector(scrubEnded(_:)), for: .touchUpInside)

        let sliderTapGesture =  UITapGestureRecognizer(target: self, action: #selector(progressSliderTapped(_:)))
        mainView.progressSlider.addGestureRecognizer(sliderTapGesture)

    }

    private func bindPlayerCallbacks() {

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
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.updateFooterView(for: traitCollection)
        mainView.dropdown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }

}

#Preview(){
    UINavigationController(rootViewController: MainViewController())
}
