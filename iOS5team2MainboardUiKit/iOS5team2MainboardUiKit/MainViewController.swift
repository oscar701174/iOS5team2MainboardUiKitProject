import UIKit
import AVFoundation

final class PlayerView: UIView {
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

    let label = UILabel()
    
    let languageButton = UIButton()
    let searchButton = UIButton()
    
    let playerView = PlayerView()
    let progressView =  UIProgressView(progressViewStyle: .default)
    
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // setLabel()
        setHeader()
        configureLanguageMenu()
        setTopVideo()
        view.backgroundColor = AppColor.background
    }

    func setLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        label.text = "Goodluck,Team2 Mainboard!"
        label.textAlignment = .center
        label.textColor = .yellow
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
            UIAction(title: "Java", image: UIImage(named: "java")?.resized(to: .init(width: 34, height: 34)), handler: { _ in
                self.languageButton.setImage(UIImage(named: "java")?.resized(to: .init(width: 34, height: 34)), for: .normal)
                self.languageButton.setTitle("Java", for: .normal)
            }),
            UIAction(title: "C", image: UIImage(named: "c")?.resized(to: .init(width: 34, height: 34)), handler: { _ in
                self.languageButton.setImage(UIImage(named: "c")?.resized(to: .init(width: 34, height: 34)), for: .normal)
                self.languageButton.setTitle("C", for: .normal)
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

        let url = URL(string:"https://kxc.blob.core.windows.net/est2/video.mp4")!
        let player = AVPlayer(url: url)
        self.player = player
        playerView.player = player
        playerView.player = player
        playerView.playerLayer.videoGravity = .resizeAspect
    }

    func setProgressBar() {
        view.addSubview(progressView)
        
        
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
