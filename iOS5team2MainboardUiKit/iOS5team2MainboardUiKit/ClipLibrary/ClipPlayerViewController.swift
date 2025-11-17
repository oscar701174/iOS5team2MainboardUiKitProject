import UIKit
import AVKit

class ClipPlayerViewController: UIViewController {
    let clipManager = ClipManager()
    var deviceOrientation: UIDeviceOrientation = .portrait
    var heightRatioConstraint: NSLayoutConstraint?
    let mainStackContainer = UIStackView()
    let videoContainer = UIView() // video를 담는 container
    let clipStackContainer = UIStackView() // clipContainer와 memoContainer를 깜싸는 stackView
    let clippingButton = UIButton(configuration: .glass()) // clipActionButton view
    let memoView = UITextField()  // memo를 담는 container view
    var video: VideoModel
    var currentPlayingTime: Double = 0.0
    var playingTime: Double = 0.0 {
        didSet{
            if clips.isEmpty {
                video.clips?.append(ClipModel(start: 0.0, end: playingTime))
                addClip(from: 0.0, to: playingTime)
            }
        }
    }
    
    var clipIndexTouched: Int? {
        didSet {
            guard let clipIndex = clipIndexTouched else {return }
            updateMemoView(by: clipIndex)
        }
    }
    
    var clippedVideo: [Double] {
        didSet {
            if clippedVideo.count == 1 {
                clippingButton.isSelected = true
            }
            
            if clippedVideo.count == 2 {
                addClip(from: clippedVideo[0], to: clippedVideo[1])
                clippedVideo = []
                clippingButton.isSelected = false
            }
        }
    }
    
    var clips: [ClipModel] {
        didSet {
            clips.sort { $0.start < $1.start }
            updateClipContainer()
        }
    }
    
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
}

extension ClipPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self,#function)
        ClipPlayer.shared.video = self.video
        loadMainStack()
        loadMainStackConstraint()
        loadClipStackContainer()
        loadClippingButton()
        loadMemoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self,#function)
        appearVideoContainer()
        guard let durationToPlayToEnd = ClipPlayer.shared.durationTimeToEnd else {return}
        let seconds = Double(durationToPlayToEnd.seconds)
        print(seconds)
        self.playingTime = Double(round(seconds * 10) / 10)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print(self,#function)
        coordinator.animate(alongsideTransition: nil) { _ in
            let isLandscape = size.width > size.height
            self.deviceOrientation = isLandscape ? .landscapeLeft : .portrait
            self.updateClipContainer()
        }
        print(self,#function,size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let orientation = UIDevice.current.orientation
        print(self,#function,orientation)
        if orientation.isPortrait == true {
            deviceOrientation = .portrait
        } else if orientation.isLandscape == true {
            deviceOrientation = .landscapeLeft
        }
        updateContainerAxis()
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
        self.currentPlayingTime = Double(round(seconds * 10) / 10)
    }
    
    func clipPlayer(_ clipPlayer: ClipPlayer, durationToPlayToEnd: CMTime) {
        let seconds = Double(durationToPlayToEnd.seconds)
        print(seconds)
        self.playingTime = Double(round(seconds * 10) / 10)
    }
}

extension ClipPlayerViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        print(self,#function)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
    }
}

