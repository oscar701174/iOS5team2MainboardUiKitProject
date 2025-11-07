import UIKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            preconditionFailure("Expected AVPlayerLayer, got \(type(of: layer))")
        }

        return layer
    }

    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
}

class MainViewController: UIViewController {

    let start = UILabel()
    let end = UILabel()

    let languageButton = UIButton()
    let searchButton = UIButton()
    let forward15sButton = UIButton()
    let playButton = UIButton()
    let rewind15sButton = UIButton()
    let airPlayButton = UIButton()
    let ellipsisButton = UIButton()

    let playerView = PlayerView()
    let buttonStackView = UIStackView()

    var player: AVPlayer?
    var timeObserver: Any?

    let progressSlider = UISlider()
    override func viewDidLoad() {
        super.viewDidLoad()
        // setLabel()
        setHeader()
        configureLanguageMenu()
        setTopVideo()
        if let player = self.player {
            setProgressSlider(player: player)
        }
        setVideoButton()
        playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        view.backgroundColor = AppColor.background
    }

    func setHeader() {
        view.addSubview(languageButton)
        view.addSubview(searchButton)

        languageButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            languageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            languageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -10),
            languageButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])

        languageButton.setTitle("Swift", for: .normal)
        languageButton.setImage(UIImage(named: "swift")?.resized(to: .init(width: 34, height: 34)), for: .normal)
        languageButton.titleEdgeInsets.left = 10
        languageButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        searchButton.setImage(img, for: .normal)
        searchButton.tintColor = .white

        languageButton.showsMenuAsPrimaryAction = true
        languageButton.clipsToBounds = true
    }

    func configureLanguageMenu() {
        let actions: [UIAction] = [
            UIAction(title: "Swift", image: UIImage(named: "swift")?.resized(to: .init(width: 34, height: 34)), handler: { _ in
                self.languageButton.setImage(UIImage(named: "swift")?.resized(to: .init(width: 34, height: 34)), for: .normal)
                self.languageButton.setTitle("Swift", for: .normal)
            }),
            UIAction(title: "Java", image: UIImage(named: "Kotlin")?.resized(to: .init(width: 34, height: 34)), handler: { _ in
                self.languageButton.setImage(UIImage(named: "Kotlin")?.resized(to: .init(width: 34, height: 34)), for: .normal)
                self.languageButton.setTitle("Kotlin", for: .normal)
            }),
            UIAction(title: "PHP", image: UIImage(named: "PHP")?.resized(to: .init(width: 34, height: 34)), handler: { _ in
                self.languageButton.setImage(UIImage(named: "PHP")?.resized(to: .init(width: 34, height: 34)), for: .normal)
                self.languageButton.setTitle("PHP", for: .normal)
            })
        ]
        languageButton.menu = UIMenu(children: actions)
    }

    func setTopVideo() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0/16.0)
        ])
    
        guard let url = URL(string: "https://kxc.blob.core.windows.net/est2/video.mp4") else {
            return
        }
        let player = AVPlayer(url: url)
        self.player = player
        playerView.player = player
        playerView.player = player
        playerView.playerLayer.videoGravity = .resizeAspect

    }

    func setProgressSlider(player: AVPlayer) {
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)

        start.text = "00:00:00"
        end.text = "00:00:00"

        start.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        end.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        start.textColor = AppColor.menuIcon
        end.textColor = AppColor.menuIcon

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

            self.progressSlider.value = max(0, min(1, Float(player.currentTime().seconds / item.duration.seconds)))
        }

        view.addSubview(progressSlider)
        view.addSubview(start)
        view.addSubview(end)

        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        start.translatesAutoresizingMaskIntoConstraints = false
        end.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressSlider.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 30),
            progressSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            progressSlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            start.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            start.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            end.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -3),
            end.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)

        ])

        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: cfg), for: .normal)

        progressSlider.thumbTintColor = AppColor.menuIcon
        progressSlider.maximumTrackTintColor = AppColor.menuIcon.withAlphaComponent(0.5)

    }

    func setVideoButton() {
        let playButtons: [UIButton] = [forward15sButton, playButton, rewind15sButton]

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

        view.addSubview(airPlayButton)
        view.addSubview(buttonStackView)
        view.addSubview(ellipsisButton)

        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10

        playButtons.forEach { btn in
            buttonStackView.addArrangedSubview(btn)
        }

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        airPlayButton.translatesAutoresizingMaskIntoConstraints = false
        ellipsisButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            airPlayButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            airPlayButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 15),
            ellipsisButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            ellipsisButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 22)
        ])
    }

    @objc private func playButtonTapped(_ sender: UIButton) {
        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        
        if playerView.player?.timeControlStatus == .paused {
            playButton.setImage(UIImage(systemName: "pause.fill",
                                        withConfiguration: playButtonCFG), for: .normal)
            playerView.player?.play()
        } else {
            playerView.player?.pause()
            playButton.setImage(UIImage(systemName: "play.fill",
                                        withConfiguration: playButtonCFG), for: .normal)
        }
       
    }

    deinit {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
    }
}

#Preview(){
    MainViewController()
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
