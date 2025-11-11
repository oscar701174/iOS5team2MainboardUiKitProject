import UIKit
import AVFoundation
import DropDown

class MainViewController: UIViewController {

    var isSearchButtonActive = true

    var player: AVPlayer?
    var timeObserver: Any?
    var didReachEnd = false
    var playingVideoURL: URL?
    let mainView = MainLayout()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startPlayback(with: playingVideoURL)
        
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
        mainView.clipButton.addTarget(self, action: #selector(pushMyClipScreen(_:)), for: .touchUpInside)
        mainView.tagButton.addTarget(self, action: #selector(pushTagScreen(_:)), for: .touchUpInside)
        mainView.settingButton.addTarget(self, action: #selector(pushSettingScreen(_:)), for: .touchUpInside)

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
    UINavigationController(rootViewController: MainViewController())
}
