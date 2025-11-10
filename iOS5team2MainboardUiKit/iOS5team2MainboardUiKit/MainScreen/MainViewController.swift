import UIKit
import AVFoundation
import DropDown

class MainViewController: UIViewController {

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var didReachEnd = false

    private let mainView = MainLayout()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.setHeader()
        mainView.configureLanguageMenu()
        mainView.setTopVideo()
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
        mainView.setProgressSlider()
        mainView.setVideoButton()
        mainView.setVideoCollection()
        mainView.setBottomMenu()

        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self

        mainView.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        mainView.languageButton.addTarget(self, action: #selector(dropdownClick(_:)), for: .touchUpInside)
        mainView.forward15sButton.addTarget(self, action: #selector(forward15sButtonTapped(_:)), for: .touchUpInside)
        mainView.rewind15sButton.addTarget(self, action: #selector(rewind15sButtonTapped(_:)), for: .touchUpInside)

    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.dropdown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }

    func addProgressObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)

        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] _ in
            guard let self, let item = player.currentItem else {
                return
            }

            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else {
                return
            }

            mainView.progressSlider.value = max(0, min(1, Float(player.currentTime().seconds / item.duration.seconds)))
            mainView.start.text = TimeFormatter.timeFormat(player.currentTime().seconds)

        }
    }

    func addPlayEndObserver() {
        guard let playerItem = player?.currentItem else {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    func skipForwardSeconds(player: AVPlayer) {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        guard durationSeconds.isFinite else { return }

        let currentTime = player.currentTime().seconds
        let newTime = min(currentTime + 15, durationSeconds - 0.1)
        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func skipRewindSeconds(player: AVPlayer) {
        let currentTime = player.currentTime().seconds
        let newTime = max(currentTime - 15, 0)

        let targetTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc private func playButtonTapped(_ sender: UIButton) {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if didReachEnd == true {
            didReachEnd = false
            player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        if mainView.playerView.player?.timeControlStatus == .paused {
            mainView.playButton.setImage(UIImage(systemName: "pause.fill",
                                        withConfiguration: playButtonCFG), for: .normal)
            mainView.playerView.player?.play()
        } else if mainView.playerView.player?.timeControlStatus == .playing {
            mainView.playerView.player?.pause()
            mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                        withConfiguration: playButtonCFG), for: .normal)
        }
    }

    @objc private func forward15sButtonTapped(_ sender: UIButton) {
        guard let player else {
            return
        }
        skipForwardSeconds(player: player)
    }

    @objc private func rewind15sButtonTapped(_ sender: UIButton) {
        guard let player else {
            return
        }
        skipRewindSeconds(player: player)
    }

    @objc private func dropdownClick(_ sender: UIButton) {
        mainView.dropdown.show()
    }

    @objc private func handlePlayEnd() {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
       // player?.seek(to: .zero)
        player?.pause()
        didReachEnd = true
        mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                            withConfiguration: playButtonCFG), for: .normal)
        mainView.progressSlider.value = 1

        if let duration = player?.currentItem?.duration.seconds, duration.isFinite {
            mainView.start.text = TimeFormatter.timeFormat(duration)
        }
    }

    deinit {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 // 데이터 개수
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let raw = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseID, for: indexPath)
        guard let cell = raw as? VideoCell else { return raw }
        cell.configure( thumbnail: UIImage(named: "sample"),
                        title: "이것은 테스트를 위한 임시 문구 입니다. \(indexPath.item)"
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                        withReuseIdentifier: "footer", for: indexPath)
    }

}

#Preview(){
    MainViewController()
}
