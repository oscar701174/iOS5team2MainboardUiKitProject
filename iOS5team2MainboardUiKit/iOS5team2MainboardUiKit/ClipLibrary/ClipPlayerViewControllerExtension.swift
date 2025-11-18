import UIKit
import AVKit

// MARK: - Layout / Orientation Update
extension ClipPlayerViewController {

    /// # updateContainerAxis
    /// 기기 회전(Portrait / Landscape)에 따라 메인 스택 구조를 재배치합니다.
    ///
    /// - 세로(Portrait): 영상 위 / 클립 아래 (vertical)
    /// - 가로(Landscape): 영상 왼쪽 / 클립 오른쪽 (horizontal)
    ///
    /// mainStackContainer, videoContainer, clipStackContainer가 모두 영향을 받습니다.
    func updateContainerAxis() {

        // 기존 비율 제약 비활성화
        heightRatioConstraint?.isActive = false
        heightRatioConstraint = nil

        if deviceOrientation.isPortrait {
            // 세로 레이아웃 → 상단 영상, 하단 클립
            mainStackContainer.axis = .vertical

            // 영상 높이 : 클립 높이 = 1.5 : 1
            let constraint = videoContainer.heightAnchor.constraint(
                equalTo: clipStackContainer.heightAnchor,
                multiplier: 1.5
            )
            constraint.isActive = true
            heightRatioConstraint = constraint

            clipStackContainer.alignment = .fill

        } else if deviceOrientation.isLandscape {
            // 가로 레이아웃 → 좌측 영상, 우측 클립
            mainStackContainer.axis = .horizontal

            // 영상 폭 : 클립 폭 = 4 : 1
            let constraint = videoContainer.widthAnchor.constraint(
                equalTo: clipStackContainer.widthAnchor,
                multiplier: 4.0
            )
            constraint.isActive = true
            heightRatioConstraint = constraint

            clipStackContainer.alignment = .fill
        }
    }

    /// # updateClipContainer
    /// UIStackView에 등록된 기존 클립 버튼들을 모두 제거하고 다시 로드합니다.
    /// (클립이 생성/삭제/수정된 경우 호출됨)
    func updateClipContainer() {
        clipStackContainer.arrangedSubviews.forEach { sub in
            clipStackContainer.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        loadClipStackContainer()
    }

    /// # updateMemoView
    /// 현재 선택된 클립 인덱스에 맞는 메모를 메모 입력창에 반영합니다.
    func updateMemoView(by clipIndex: Int) {
        guard let memo = clips[clipIndex].title else { return }
        memoView.text = memo
    }
}

// MARK: - UI Setup
extension ClipPlayerViewController {

    /// # loadMainStack
    /// 메인 스택 구조에 영상 영역 / 클립 영역을 추가하여 전체 UI 구조를 생성합니다.
    func loadMainStack() {
        mainStackContainer.addArrangedSubview(videoContainer)
        mainStackContainer.addArrangedSubview(clipStackContainer)
        mainStackContainer.spacing = 10
        mainStackContainer.alignment = .fill
        mainStackContainer.distribution = .fill
        view.addSubview(mainStackContainer)
    }

    /// # loadMainStackConstraint
    /// mainStackContainer가 화면 전체를 채우도록 오토레이아웃을 등록합니다.
    func loadMainStackConstraint() {
        mainStackContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    /// # loadClipStackContainer
    /// 클립 스택뷰 내부 구성 요소(클립 버튼들 + 메모 입력창)를 설정합니다.
    func loadClipStackContainer() {
        clipStackContainer.addArrangedSubview(clippingButton)
        clipStackContainer.spacing = 10
        clipStackContainer.axis = .vertical

        // ScrollView 기반 클립 버튼 영역
        guard let clipContainer = returnScrollableClipContainer(by: deviceOrientation) else { return }
        clipStackContainer.addArrangedSubview(clipContainer)

        // 메모 입력창
        clipStackContainer.addArrangedSubview(memoView)
    }

    /// # loadClippingButton
    /// “clip” 버튼의 UI 및 행동을 설정합니다.
    /// 버튼 클릭 → 현재 재생시간을 클립 시작/종료 시간으로 기록.
    func loadClippingButton() {
        let recordTimeAction = UIAction(title: "record time") { [weak self] _ in
            guard let self else { return }
            clippedVideo.append(self.currentPlayingTime)
        }

        clippingButton.setTitle("clip", for: .normal)
        clippingButton.setTitle("CLIPPING...", for: .selected)
        clippingButton.layer.borderWidth = 1
        clippingButton.layer.borderColor = UIColor.main.cgColor
        clippingButton.tintColor = .main.withAlphaComponent(0.3)
        clippingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        clippingButton.addAction(recordTimeAction, for: .touchUpInside)

        clippingButton.configurationUpdateHandler = { button in
            var config = button.configuration
            if button.isSelected {
                config?.baseForegroundColor = UIColor.main.withAlphaComponent(0.3)
            } else {
                config?.background.backgroundColor = .clear
            }
        }
    }

    /// # loadMemoView
    /// 메모 표시 및 편집을 위한 UITextField를 설정합니다.
    func loadMemoView() {
        memoView.borderStyle = .roundedRect
        memoView.layer.cornerRadius = 8
        memoView.layer.borderColor = UIColor.main.cgColor
        memoView.placeholder = ""
        memoView.isEnabled = false // 기본은 읽기 전용

        memoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(memoViewTapped(_:)))
        memoView.addGestureRecognizer(singleTap)
    }

    /// # appearVideoContainer
    /// 영상 재생 UI를 생성하고 ClipPlayer에 영상 로드를 요청합니다.
    func appearVideoContainer() {
        videoContainer.backgroundColor = .black
        ClipPlayer.shared.embedInline(in: self, container: videoContainer)
        ClipPlayer.shared.video = video
    }

    /// # returnClipButtons
    /// 현재 보유한 모든 클립을 버튼(UI)로 변환하여 배열로 반환합니다.
    func returnClipButtons() -> [UIButton]? {
        var clipButtons: [UIButton] = []

        for (index, clip) in clips.enumerated() {
            let clipButton = UIButton(configuration: .glass())
            clipButton.setTitle("\(clip.start.toMinuteSecond)-\(clip.end.toMinuteSecond)", for: .normal)
            clipButton.backgroundColor = .main
            clipButton.setTitleColor(.white, for: .normal)
            clipButton.tag = index

            // 탭 = 메모 보기
            clipButton.addTarget(self, action: #selector(clipButtonTapped(_:)), for: .touchUpInside)

            // 더블탭 = 즉시 재생
            clipButton.addTarget(self, action: #selector(clipButtonDoubleTapped(_:)), for: .touchDownRepeat)

            // 롱프레스 = 삭제
            clipButton.addGestureRecognizer(
                UILongPressGestureRecognizer(target: self, action: #selector(clipButtonLongPressed(_:)))
            )

            clipButtons.append(clipButton)
        }
        return clipButtons
    }

    /// # returnScrollableClipContainer
    /// 디바이스 방향에 따라 가로 또는 세로 스크롤이 가능한 클립 컨테이너를 반환합니다.
    func returnScrollableClipContainer(by deviceOrientation: UIDeviceOrientation) -> MyScrollableContainer? {
        guard let clipButtons = returnClipButtons() else { return nil }

        if deviceOrientation.isPortrait {
            return MyScrollableContainer(contents: clipButtons, scrollMode: .horizontal)
        } else {
            return MyScrollableContainer(contents: clipButtons, scrollMode: .vertical)
        }
    }
}

// MARK: - Clip Button Events (Tap, Double Tap, Long Press)
extension ClipPlayerViewController {

    /// # resolveVideoEntity
    /// 현재 재생 중인 VideoModel이 CoreData의 어떤 VideoEntity인지 매칭하여 반환합니다.
    ///
    /// - 번들 URL → bundleURL()을 통해 비교
    /// - 일반 파일 URL → entity.url 직접 비교
    private func resolveVideoEntity() -> VideoEntity? {
        let manager = VideoManager()
        let entities = manager.fetch()

        let currentURL = self.video.filePath

        for entity in entities {

            // 1) 번들 영상인지 비교
            if let resolved = manager.bundleURL(for: entity), resolved == currentURL {
                return entity
            }

            // 2) 일반 URL 비교
            if let raw = entity.url, let rawURL = URL(string: raw), rawURL == currentURL {
                return entity
            }
        }
        return nil
    }

    /// # addClip
    /// 새 클립(시작/종료 시간 기반)을 메모리와 CoreData에 동시에 기록합니다.
    @objc func addClip(from start: Double, to end: Double) {

        let clip = ClipModel(start: start, end: end, title: nil)
        clips.append(clip)

        // CoreData 저장
        if let videoEntity = resolveVideoEntity() {
            clipManager.createClip(
                video: videoEntity,
                title: clip.title ?? "",
                startSeconds: clip.start,
                endSeconds: clip.end
            )
        }
    }

    /// # clipButtonTapped
    /// 단일 탭 → 해당 클립의 메모(텍스트)를 확인하고 편집 가능하도록 설정.
    @objc func clipButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < clips.count else { return }

        clipIndexTouched = index
        memoView.text = ""
        memoView.placeholder = "메모 입력"
        memoView.layer.borderWidth = 2
        memoView.isEnabled = true

        updateMemoView(by: index)
    }

    /// # clipButtonDoubleTapped
    /// 더블 탭 → 해당 클립 구간을 즉시 재생.
    @objc func clipButtonDoubleTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < clips.count else { return }

        ClipPlayer.shared.playClip(clips[index])
    }

    /// # clipButtonLongPressed
    /// 롱프레스 → 해당 클립 삭제 + CoreData 삭제
    @objc func clipButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let button = sender.view as? UIButton else { return }

        let index = button.tag
        guard index < clips.count else { return }

        let alert = UIAlertController(
            title: "Clip 삭제",
            message: "해당 클립을 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }

            // 1) 삭제할 target 먼저 저장
            let target = self.clips[index]

            // 2) CoreData에서 삭제
            if let videoEntity = self.resolveVideoEntity() {
                let clipEntities = self.clipManager.fetchClips(for: videoEntity)

                if let entity = clipEntities.first(where: {
                    abs($0.startSeconds - target.start) < 0.001 &&
                    abs($0.endSeconds - target.end) < 0.001
                }) {
                    self.clipManager.delete(entity)
                }
            }

            // 3) 마지막에 배열에서 제거
            self.clips.remove(at: index)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    /// # memoViewTapped
    /// 메모 영역을 터치하면 편집 UI를 띄웁니다.
    @objc func memoViewTapped(_ sender: UIView) {
        memoView.text = ""
        showMemoEditor()
    }

    /// # showMemoEditor
    /// UIAlertController 기반 메모 작성/수정 창
    func showMemoEditor() {

        let alert = UIAlertController(
            title: "# memo tag",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "memo tag 입력(15자 이내)"
            if let index = self.clipIndexTouched {
                textField.text = self.clips[index].title
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            guard let index = self.clipIndexTouched else { return }

            let memo = String(text.prefix(15))
            self.clips[index].title = memo

            // CoreData 업데이트
            if let videoEntity = self.resolveVideoEntity() {
                let clipEntities = self.clipManager.fetchClips(for: videoEntity)
                if index < clipEntities.count {
                    clipEntities[index].title = memo
                    self.clipManager.save()
                }
            }

            self.memoView.text = memo
        })

        present(alert, animated: true) {
            if let index = self.clipIndexTouched {
                self.updateMemoView(by: index)
            }
        }
    }
}

// MARK: - Helpers
extension Double {
    /// double 값을 mm:ss 포맷 문자열로 변환
    var toMinuteSecond: String {
        let total = Int(self)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

/// CoreData에서 클립 목록을 다시 불러와 메모리 모델(clips)에 반영
extension ClipPlayerViewController {
    func loadClipsFromCoreData() {
        if let videoEntity = resolveVideoEntity() {
            self.clips = clipManager.fetchClips(for: videoEntity).map {
                ClipModel(start: $0.startSeconds, end: $0.endSeconds, title: $0.title)
            }
        } else {
            self.clips = []
        }
    }
}

