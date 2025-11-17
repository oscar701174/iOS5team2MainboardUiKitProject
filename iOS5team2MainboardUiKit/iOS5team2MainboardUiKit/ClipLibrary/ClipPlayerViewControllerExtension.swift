import UIKit
import AVKit

//update
extension ClipPlayerViewController {
    // 가로,세로모드 변화에 따른 mainStackContainer와 clipStackContainer 설정 업데이트
    func updateContainerAxis() {
        heightRatioConstraint?.isActive = false
        heightRatioConstraint = nil
        
        if deviceOrientation.isPortrait {
            mainStackContainer.axis = .vertical
            let constraint = videoContainer.heightAnchor.constraint(
                equalTo: clipStackContainer.heightAnchor,
                multiplier: 1.5
            )
            constraint.isActive = true
            heightRatioConstraint = constraint
            clipStackContainer.alignment = .fill
        } else if deviceOrientation.isLandscape {
            mainStackContainer.axis = .horizontal
            let constraint = videoContainer.widthAnchor.constraint(
                equalTo: clipStackContainer.widthAnchor,
                multiplier: 4.0
            )
            constraint.isActive = true
            heightRatioConstraint = constraint
            clipStackContainer.alignment = .fill
        }
    }
    // clipContainer update
    func updateClipContainer() {
        clipStackContainer.arrangedSubviews.forEach { sub in
            clipStackContainer.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        loadClipStackContainer()
    }
    // memoView update
    func updateMemoView(by clipIndex: Int) {
        guard let memo = clips[clipIndex].title else { return }
        memoView.text = memo
    }
}

//setup
extension ClipPlayerViewController {
    //mainStackContainer 설정.
    func loadMainStack() {
        mainStackContainer.addArrangedSubview(videoContainer)
        mainStackContainer.addArrangedSubview(clipStackContainer)
        mainStackContainer.spacing = 10
        mainStackContainer.alignment = .fill
        mainStackContainer.distribution = .fill
        view.addSubview(mainStackContainer)
        print(self,#function)
    }
    
    func loadMainStackConstraint() {
        mainStackContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            mainStackContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mainStackContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mainStackContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        print(self,#function)
    }
    
    func loadClipStackContainer() {
        
        clipStackContainer.addArrangedSubview(clippingButton)
        clipStackContainer.spacing = 10
        clipStackContainer.axis = .vertical
        clipStackContainer.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        clipStackContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        guard let clipContainer = returnScrollableClipContainer(by: deviceOrientation) else { return }
        
        clipStackContainer.addArrangedSubview(clipContainer)
        clipStackContainer.addArrangedSubview(memoView)
        print(self,#function)
    }
    
    func loadClippingButton() {
        let recordTimeAction = UIAction(title: "record time") { [weak self] _ in
            guard let self else { return }
            clippedVideo.append(self.currentPlayingTime)
        }
        clippingButton.setTitle("clip", for: .normal)
        clippingButton.setTitle("CLIPPING...", for: .selected)
        clippingButton.titleLabel?.textAlignment = .center
        clippingButton.backgroundColor = .clear
        clippingButton.layer.borderWidth = 1
        clippingButton.layer.borderColor = UIColor.main.cgColor
        clippingButton.tintColor = .main.withAlphaComponent(0.3)
        clippingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        clippingButton.addAction(recordTimeAction, for: .touchUpInside)
        clippingButton.configurationUpdateHandler = { button in
            var config = button.configuration
            if  button.isSelected {
                config?.baseForegroundColor = UIColor.main.withAlphaComponent(0.3)
            } else {
                config?.background.backgroundColor = .clear
            }
        }
        print(self,#function)
    }
    
    func loadMemoView() {
        memoView.borderStyle = .roundedRect
        memoView.layer.borderWidth = 0
        memoView.layer.cornerRadius = 8
        memoView.layer.borderColor = UIColor.main.cgColor
        memoView.placeholder = ""
        memoView.isEnabled = false
        memoView.translatesAutoresizingMaskIntoConstraints = false
        memoView.inputView = UIView()
        memoView.inputAccessoryView = UIView()
        // 최소 높이 50 유지
        let minHeight = memoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        minHeight.isActive = true
        // clipStackContainer 안에서 아래 공간을 모두 차지하도록 우선순위 설정
        memoView.setContentHuggingPriority(.defaultLow, for: .vertical)
        memoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(memoViewTapped(_:)))
 
        memoView.addGestureRecognizer(singleTap)
        
        print(self,#function)
    }
    
    func appearVideoContainer() {
        videoContainer.backgroundColor = .black
        ClipPlayer.shared.embedInline(in: self, container: videoContainer)
        ClipPlayer.shared.video = video
        print(self,#function)
    }
    
    func returnClipButtons() -> [UIButton]? {
        var clipButtons: [UIButton] = []
        for (index, clip) in clips.enumerated() {
            let clipButton = UIButton(configuration: .glass())
            let startTime = clip.start.toMinuteSecond
            let endTime = clip.end.toMinuteSecond
            
            clipButton.setTitle("\(startTime)-\(endTime)", for: .normal)
            clipButton.backgroundColor = .main
            clipButton.setTitleColor(.white, for: .normal)
            clipButton.layer.cornerRadius = 8
            clipButton.tag = index
            clipButton.addTarget(self, action: #selector(clipButtonTapped(_:)), for: .touchUpInside)
            clipButton.addTarget(self, action: #selector(clipButtonDoubleTapped(_:)), for: .touchDownRepeat)

            clipButtons.append(clipButton)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(clipButtonLongPressed(_:)))
            clipButton.addGestureRecognizer(longPress)
        }
        print(self,#function)
        return clipButtons
    }
    
    func returnScrollableClipContainer(by deviceOrientation: UIDeviceOrientation) -> MyScrollableContainer? {
        
        guard let clipButtons = returnClipButtons() else { return nil }
        if deviceOrientation.isPortrait {
            let clipContainer = MyScrollableContainer(contents: clipButtons, scrollMode: .horizontal)
            print(self,#function,"portrait")
            return clipContainer
        }else {
            let clipContainer = MyScrollableContainer(contents: clipButtons, scrollMode: .vertical)
            print(self,#function,"landscape")
            return clipContainer
        }
    }
}

//button event
extension ClipPlayerViewController {
    @objc func addClip(from start: Double, to end: Double) {
        let clip = ClipModel(start: start, end: end, title: nil)
        clips.append(clip)
        
        //MARK: CoreData
        if let videoEntity = self.video.entityReference {
            clipManager.createClip(
                video: videoEntity,
                title: clip.memo ?? "",
                startSeconds: clip.start,
                endSeconds: clip.end
            )
        }
    }
    
    @objc func clipButtonTapped(_ sender: UIButton) {
        print(self,#function)
        let index = sender.tag
        guard index < clips.count else { return }
        let clip = clips[index]
        print(clip)
        clipIndexTouched = index
        memoView.text = ""
        memoView.placeholder = "메모 입력"
        memoView.layer.borderWidth = 2
        memoView.isEnabled = true
        self.updateMemoView(by: index)
    }
    
    @objc func clipButtonDoubleTapped(_ sender: UIButton) {
        print(self,#function)
        let index = sender.tag
        guard index < clips.count else { return }
        let clip = clips[index]
   
        print(clip)
        ClipPlayer.shared.playClip(clip)
    }
    
    @objc func clipButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let button = sender.view as? UIButton else { return }
        
        let index = button.tag
        guard index < clips.count else { return }
        
        let alert = UIAlertController(title: "Clip 삭제",
                                      message: "해당 클립을 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            self.clips.remove(at: index)
            
            //MARK: CoreData, Delete from CoreData
            if let videoEntity = self.video.entityReference,
               let clipEntity = clipManager.fetchClips(for: videoEntity)[safe: index] {
                   clipManager.delete(clipEntity)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func memoViewTapped(_ sender: UIView) {
        print(self,#function)
        memoView.text = ""
        showMemoEditor()
    }
    
    func showMemoEditor() {
        
        let alert = UIAlertController(title: "# memo tag",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "memo tag 입력(15자 이내)"
            guard  let index = self.clipIndexTouched, let _ = self.clips[index].title else { return }
            textField.text = self.clips[index].memo
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text else { return }
            guard  let index = self.clipIndexTouched else { return }
            let memo = String(text.prefix(15))
            self.clips[index].title = memo
            
            //MARK: CoreData Update CoreData memo
            if let videoEntity = self.video.entityReference {
                let clipEntities = clipManager.fetchClips(for: videoEntity)
                if index < clipEntities.count {
                    clipEntities[index].title = memo
                    try? clipManager.context.save()
                }
            }
            self.memoView.text = memo
            
        }))
        
        self.present(alert, animated: true ) {
            guard let index = self.clipIndexTouched else { return }
            self.updateMemoView(by: index)
        }
    }
}

extension Double {
    var toMinuteSecond: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


extension ScrollTestUIView {
    // Assuming somewhere in init or setup:
    func loadClipsFromCoreData() {
        if let videoEntity = video.entityReference {
            self.clips = clipManager.fetchClips(for: videoEntity).map {
                ClipModel(start: $0.startSeconds, end: $0.endSeconds, memo: $0.title)
            }
        } else {
            self.clips = []
        }
    }
}
