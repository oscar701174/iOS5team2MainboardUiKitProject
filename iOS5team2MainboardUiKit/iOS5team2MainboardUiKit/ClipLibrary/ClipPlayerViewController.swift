import UIKit
import AVFoundation

class ClipPlayerViewController: UIViewController {
    private let video: VideoModel
    private var currentPlayingTime: Double = 0.0
    
    var clippedVideo: [Double] {
        didSet {
            if clippedVideo.count == 2 {
                addClip(from: clippedVideo[0], to: clippedVideo[1])
                clippedVideo = []
            }
        }
    }
    
    var clips: [ClipModel] {
        didSet {
            // 스택뷰 초기화
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }

            // 버튼 재생성
            for (index, clip) in clips.enumerated() {
                let btn = UIButton(type: .system)
                btn.setTitle(String(clip.start), for: .normal)
                btn.backgroundColor = .systemBlue
                btn.setTitleColor(.white, for: .normal)
                btn.layer.cornerRadius = 8
                btn.tag = index
                btn.addTarget(self, action: #selector(clipButtonTapped(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(btn)
            }
        }
    }
    private let videoContainer = UIView()
    private let stackView = UIStackView()
    private let clippingButton = UIButton(configuration: .glass())
    
    init(video: VideoModel) {
        self.video = video
        self.clips = video.clips ?? []
        self.clippedVideo = []
        super.init(nibName: nil, bundle: nil)
        ClipPlayer.shared.delegate = self
        clips.forEach { print("clip: \($0.start) - \($0.end)") }
    }
    
    deinit {
        ClipPlayer.shared.delegate = nil
        print(self,#function)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = video.title
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addClip)
        )
        
        view.backgroundColor = .systemBackground
        
        videoContainer.backgroundColor = .black
        videoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoContainer)
        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35)
        ])
        
        let recordTimeAction = UIAction(title: "record time") { [weak self] _ in
            guard let self else { return }
            clippedVideo.append(self.currentPlayingTime)
        }
        clippingButton.setTitle("clip", for: .normal)
        clippingButton.titleLabel?.textAlignment = .center
        clippingButton.addAction(recordTimeAction, for: .touchUpInside)
        view.addSubview(clippingButton)
        clippingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clippingButton.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 8),
            clippingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            clippingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            clippingButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: clippingButton.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ClipPlayer.shared.embedInline(in: self, container: videoContainer)
        ClipPlayer.shared.video = video
        
        for (index, clip) in clips.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(String(clip.start), for: .normal)
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 8
            btn.tag = index
            btn.addTarget(self, action: #selector(clipButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ClipPlayer.shared.stopPlaying()
    }
}

extension ClipPlayerViewController: ClipPlayerDelegate {
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool) {
        print(self,#function,didVideoLoaded)
    }
    
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States) {
        print(self,#function)
        print(clipPlayer.playerSetStates)
    }
    
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint time: CMTime) {
        let seconds = Double(time.seconds)
        self.currentPlayingTime = seconds
    }
}

extension ClipPlayerViewController {
    @objc func addClip(from start: Double, to end: Double) {
        let clip = ClipModel(start: start, end: end)
        clips.append(clip)
    }
    
    @objc func clipButtonTapped(_ sender: UIButton) {
        print(self,#function)
        let index = sender.tag
        guard index < clips.count else { return }
        let clip = clips[index]
        print(clip)
        ClipPlayer.shared.playClip(clip)
    }
    
}
