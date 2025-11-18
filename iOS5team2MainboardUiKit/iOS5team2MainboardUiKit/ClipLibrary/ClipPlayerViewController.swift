import UIKit
import AVKit

/// # ClipPlayerViewController
/// 개별 VideoModel을 재생하며,
/// - 클립 생성 / 수정 / 삭제
/// - 메모(Tag) 편집
/// - 기기 회전 대응 UI 재배치
/// - ClipPlayer(AVPlayer 래핑) Delegate 처리
///
/// 을 담당하는 ViewController.
class ClipPlayerViewController: UIViewController {

    // MARK: - Managers / Repositories

    /// CoreData 기반 클립 데이터 관리 매니저
    let clipManager = ClipManager()

    // MARK: - Orientation / Constraints

    /// 현재 기기 방향(Portrait / Landscape)
    var deviceOrientation: UIDeviceOrientation = .portrait

    /// 영상 영역과 클립 영역의 비율을 유지하는 데 사용되는 동적 제약
    var heightRatioConstraint: NSLayoutConstraint?

    // MARK: - UI Containers

    /// 영상 영역 + 클립 영역을 감싸는 최상위 UIStackView
    let mainStackContainer = UIStackView()

    /// 영상(AVPlayerViewController)이 embed되는 컨테이너
    let videoContainer = UIView()

    /// 클립 버튼들 + 메모 입력창을 포함하는 세로 스택 컨테이너
    let clipStackContainer = UIStackView()

    /// 클립 생성 버튼(Clip 시작/종료 시간 기록)
    let clippingButton = UIButton(configuration: .glass())

    /// 메모 텍스트 입력창
    let memoView = UITextField()

    // MARK: - Video / Clip Data

    /// 현재 재생 중인 영상 모델
    var video: VideoModel

    /// Player로부터 전달받는 현재 재생 위치(seconds)
    var currentPlayingTime: Double = 0.0

    /// 영상의 전체 길이(종료 시각). 최초 로드시 자동 세팅됨.
    var playingTime: Double = 0.0 {
        didSet {
            if clips.isEmpty {
                addClip(from: 0.0, to: playingTime)
            }
        }
    }

    /// 현재 선택된 클립 index (메모 갱신 시 필요)
    var clipIndexTouched: Int? {
        didSet {
            guard let clipIndex = clipIndexTouched else { return }
            updateMemoView(by: clipIndex)
        }
    }

    /// Clip 생성 시 사용하는 start/end 시간 기록 배열
    /// - count == 1 → 시작 지점 저장
    /// - count == 2 → 종료 지점 저장 → 클립 생성
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

    /// 현재 영상의 클립 목록
    var clips: [ClipModel] {
        didSet {
            // 항상 시간 오름차순 정렬
            clips.sort { $0.start < $1.start }
            updateClipContainer()
        }
    }

    // MARK: - Init

    init(video: VideoModel) {
        self.video = video
        self.clips = []
        self.clippedVideo = []
        super.init(nibName: nil, bundle: nil)
        ClipPlayer.shared.delegate = self
    }

    deinit {
        // Delegate 해제
        ClipPlayer.shared.delegate = nil
        print(self, #function)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ClipPlayerViewController {

    /// 최초 View 로드시 UI 구성 및 기본 설정 수행
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self, #function)

        // ClipPlayer에게 영상 전달 → 자동 loadVideo 호출됨
        ClipPlayer.shared.video = self.video

        // UI 구성
        loadClipsFromCoreData()
        loadMainStack()
        loadMainStackConstraint()
        loadClipStackContainer()
        loadClippingButton()
        loadMemoView()
      
    }

    /// View가 화면에 표시된 이후 영상 컨테이너 삽입 + 전체 길이 측정
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self, #function)

        // AVPlayerView embed
        appearVideoContainer()

        // 영상 길이 로드 완료 시점 처리
        if let durationToPlayToEnd = ClipPlayer.shared.durationTimeToEnd {
            let seconds = Double(durationToPlayToEnd.seconds)
            self.playingTime = Double(round(seconds * 10) / 10)
        }
    }

    /// 기기 회전 시 clip UI 재배치
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print(self, #function)

        coordinator.animate(alongsideTransition: nil) { _ in
            let isLandscape = size.width > size.height
            self.deviceOrientation = isLandscape ? .landscapeLeft : .portrait
            self.updateClipContainer()
        }
    }

    /// 회전 직후 실제 뷰 레이아웃 적용
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let orientation = UIDevice.current.orientation
        print(self, #function, orientation)

        // 방향 판별 후 axis 업데이트
        if orientation.isPortrait {
            deviceOrientation = .portrait
        } else if orientation.isLandscape {
            deviceOrientation = .landscapeLeft
        }
        updateContainerAxis()
    }

    /// 화면을 떠나면 영상 재생 중지
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ClipPlayer.shared.stopPlaying()
    }
}

extension ClipPlayerViewController: ClipPlayerDelegate {

    /// 영상 로드 완료 이벤트
    func clipPlayer(_ clipPlayer: ClipPlayer, didVideoLoaded: Bool) {
        print(self, #function, didVideoLoaded)
    }

    /// 재생 상태 변화 이벤트 (playing/paused/loaded 등)
    func clipPlayer(_ clipPlayer: ClipPlayer, didChangeState state: States) {
        print(self, #function)
        print(clipPlayer.playerSetStates)
    }

    /// 영상 재생 progress (0.1초 단위 업데이트)
    func clipPlayer(_ clipPlayer: ClipPlayer, currentPlayingTimePoint time: CMTime) {
        let seconds = Double(time.seconds)
        self.currentPlayingTime = Double(round(seconds * 10) / 10)
    }

    /// 전체 영상 길이 전달
    func clipPlayer(_ clipPlayer: ClipPlayer, durationToPlayToEnd: CMTime) {
        let seconds = Double(durationToPlayToEnd.seconds)
        print(seconds)
        self.playingTime = Double(round(seconds * 10) / 10)
    }
}

extension ClipPlayerViewController: UITextFieldDelegate {

    /// 메모 입력 필드 편집 가능
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    /// 메모 입력 시작 시 애니메이션
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        print(self, #function)
    }

    /// 메모 입력 종료
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
}
