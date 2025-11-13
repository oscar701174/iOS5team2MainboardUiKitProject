import UIKit
import AVKit
import AVFoundation

class ClipPlayerViewController: UIViewController {
    let asset: AVURLAsset
    let hlsURL: URL
    
    init(url: AVURLAsset, streamUrl: URL) {
        self.asset = url
        self.hlsURL = streamUrl
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        // If you don't use storyboards, it's fine to crash here to satisfy the required initializer.
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let button = UIButton(type: .system)
        button.setTitle("▶️ Play Video", for: .normal)
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func playVideo() {
        // Option 1: Use the asset directly via AVPlayerItem
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        let playerVC = AVPlayerViewController()
        playerVC.player = player

        present(playerVC, animated: true) {
            player.play()
        }

    }
    
    @objc func playHls() {
        print("playing hls",hlsURL)
        let player = AVPlayer(url: hlsURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        present(playerVC, animated: true) {
            player.play()
        }
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let item = AVPlayerItem(asset: asset)
//        let player = AVPlayer(playerItem: item)
//        let playerVC = AVPlayerViewController()
//        playerVC.player = player
//        present(playerVC, animated: true) {
//            player.play()
//        }
//    }
    
}
