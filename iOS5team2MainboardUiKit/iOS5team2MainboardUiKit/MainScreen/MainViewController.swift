import UIKit
import AVFoundation
import DropDown

class MainViewController: UIViewController {

    var isSearchButtonActive = true

    var player: AVPlayer?
    var timeObserver: Any?
    var didReachEnd = false

    let mainView = MainLayout()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "https://kxc.blob.core.windows.net/est2/video.mp4") {
            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)

            self.player = player
            mainView.playerView.player = player

            addProgressObserver(to: player)
            addPlayEndObserver()

            playerItem.asset.creationDate?.loadValuesAsynchronously(forKeys: ["duration"]) {
                DispatchQueue.main.async {
                    let durationSeconds = CMTimeGetSeconds(playerItem.asset.duration)
                    if durationSeconds.isFinite && durationSeconds > 0 {
                        self.mainView.end.text = TimeFormatter.timeFormat(durationSeconds)
                    }
                }
            }
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
        mainView.forward15sButton.addTarget(self, action: #selector(forward15sButtonTapped(_:)), for: .touchUpInside)
        mainView.rewind15sButton.addTarget(self, action: #selector(rewind15sButtonTapped(_:)), for: .touchUpInside)
        mainView.bottomSearchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)

    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.dropdown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }

    deinit {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
}


#Preview(){
    MainViewController()
}
