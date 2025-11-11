import UIKit
import SwiftUI
import AVKit
import AVFoundation

class ClipPlayerController: UIViewController {

    private var playerViewControllerIfLoaded: AVPlayerViewController?
    private var player: AVPlayer?
    private(set) var status: Status = []
    
    private func loadPlayerViewControllerIfNeeded() {
        if playerViewControllerIfLoaded == nil {
            playerViewControllerIfLoaded = AVPlayerViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else {
            print("Invalid URL")
            return
        }
        
        let video = Video(title:"sampleVideoFromApple",hlsUrl: url)
        // AVPlayerViewController 인스턴스 생성
        loadPlayerViewControllerIfNeeded()
        guard let playerViewController = playerViewControllerIfLoaded else { return }
        playerViewController.delegate = self
        
        if !playerViewController.hasContent(fromVideo: video) {
            let playerItem = AVPlayerItem(url: video.hlsUrl)
            playerViewController.player = AVPlayer(playerItem: playerItem)
            print("🎥 video url:", video.hlsUrl)
            print("🎬 player:", playerViewController.player ?? "nil")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 이미 생성된 AVPlayerViewController 재활용
        guard let playerViewController = playerViewControllerIfLoaded else { return }
        // 아직 표시되지 않았다면 present 후 재생
        if presentedViewController == nil {
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
                
            }
        }
    }
    
}


extension AVPlayerViewController {
    func hasContent(fromVideo video: Video) -> Bool {
        // player의 현재 재생 중인 아이템의 URL과
        // 새로 재생하려는 video.hlsUrl이 같은지 비교
        guard let currentItemURLAsset = player?.currentItem?.asset as? AVURLAsset else {
            return false
        }
        return currentItemURLAsset.url == video.hlsUrl
    }
}


extension ClipPlayerController: AVPlayerViewControllerDelegate {
    
    
}

extension ClipPlayerController {
    private func removeFromParentIfNeeded() {
        guard let vc = playerViewControllerIfLoaded else { return }
        // 이미 어떤 부모에 붙어 있으면 떼어낸다
        if vc.parent != nil {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }
    
    func embedInline(in parent: UIViewController, container: UIView) {
        loadPlayerViewControllerIfNeeded()
        guard let playerViewController = playerViewControllerIfLoaded,
              playerViewController.parent != parent else { return }

        removeFromParentIfNeeded()
        status.insert(.embeddedInline)

        parent.addChild(playerViewController)
        container.addSubview(playerViewController.view)

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerViewController.view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playerViewController.view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playerViewController.view.widthAnchor.constraint(equalTo: container.widthAnchor),
            playerViewController.view.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])

        playerViewController.didMove(toParent: parent)
        
        
        // URL setup and player initialization
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else {
            print("Invalid URL")
            return
        }
        let video = Video(title:"sampleVideoFromApple",hlsUrl: url)
        if !playerViewController.hasContent(fromVideo: video) {
            let playerItem = AVPlayerItem(url: video.hlsUrl)
            let player = AVPlayer(playerItem: playerItem)
            playerViewController.player = player
            player.play()
        }
        
    }
    
    
}

struct ClipPlayerViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ClipPlayerController {
        ClipPlayerController()
    }
    
    func updateUIViewController(_ uiViewController: ClipPlayerController, context: Context) {}
    
}

#Preview {
    ClipPlayerViewControllerRepresentable()
    
}




struct Status: OptionSet {
    let rawValue: Int
    
    // 개별 상태 플래그 정의
    static let readyForDisplay   = Status(rawValue: 1 << 0)  // 플레이어가 표시 준비 완료
    static let fullScreenActive  = Status(rawValue: 1 << 1)  // 전체화면 재생 중
    static let embeddedInline    = Status(rawValue: 1 << 2)  // 앱 내 임베디드 재생 중
    static let pictureInPictureActive = Status(rawValue: 1 << 3) // PiP(화면 속 화면) 활성화 중
    static let beingPresented    = Status(rawValue: 1 << 4)  // 전체화면 전환 중
    static let beingDismissed    = Status(rawValue: 1 << 5)  // 전체화면 종료 중
    
    // OptionSet은 [] 기본값으로 초기화 가능
}
