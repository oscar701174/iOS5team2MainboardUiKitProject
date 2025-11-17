import UIKit
import AVFoundation
import DropDown
import CoreData

/// # Overview
/// 메인 영상 재생 화면을 담당하는 뷰 컨트롤러입니다.
///
/// 앱의 홈 화면 역할을 하며 다음 기능을 관리합니다:
/// - UI 초기화(MainLayout)
/// - 영상 재생(AVPlayer / VideoPlayerManager)
/// - CoreData 기반 영상 목록 로딩(VideoManager)
/// - 검색, 언어 필터, 슬라이더 조작, 전체화면 전환 등 사용자 인터랙션 처리
///
/// # Discussion
/// 이 컨트롤러는 화면 구성 요소 관리와 사용자 입력 처리를 중심으로 동작합니다.
/// 실제 재생 관련 로직은 `VideoPlayerManager`에 위임되어 있어 구조적인 분리가 되어 있습니다.
///
/// - Note:
///   이 클래스는 `UICollectionView`, `UISearchBar`의 delegate도 함께 구현합니다.
class MainViewController: UIViewController {

    // MARK: - State Flags

    /// # Overview
    /// 검색 UI(SearchBar)의 표시 여부를 나타냅니다.
    var isSearchButtonActive = true

    /// # Overview
    /// AVPlayer의 시간 진행 상태를 관찰하기 위한 observer 객체입니다.
    var timeObserver: Any?

    /// # Overview
    /// 영상이 끝까지 재생되었는지 여부를 나타냅니다.
    var didReachEnd = false

    /// # Overview
    /// 현재 슬라이더 조작(스크러빙) 중인지 여부입니다.
    var isScrubbing = false

    /// # Overview
    /// 슬라이더 조작 전 영상이 재생 중이었는지 저장합니다.
    var wasPlayingBeforeScrub = false

    /// # Overview
    /// 전체 화면 전환 전 영상이 재생 중이었는지 저장합니다.
    var wasPlayingBeforeFullScreen = false

    /// # Overview
    /// 검색 모드 활성화 여부입니다.
    var isSearching = false

    /// # Overview
    /// 현재 재생 중인 영상의 URL입니다.
    var playingVideoURL: URL?

    /// # Overview
    /// 현재 선택된 영상(VideoEntity)입니다.
    ///
    /// - Note:
    ///   클립 저장 시 필요한 참조입니다.
    var selectedVideo: VideoEntity?

    // MARK: - View & Managers

    /// # Overview
    /// 메인 화면의 모든 UI 요소를 포함하는 레이아웃 뷰입니다.
    let mainView = MainLayout()

    /// # Overview
    /// AVPlayer 제어를 담당하는 매니저입니다.
    ///
    /// # Discussion
    /// 재생, 일시정지, 배속, 전체화면, 슬라이더 이동 등
    /// AVPlayer 관련 모든 기능을 이 매니저에 위임합니다.
    let playerManager = VideoPlayerManager()

    /// # Overview
    /// 전체 영상 목록을 담고 있는 배열입니다.
    var videoList: [VideoEntity] = []

    /// # Overview
    /// 검색된 결과 목록입니다.
    var filteredVideos: [VideoEntity] = []

    /// # Overview
    /// CoreData 기반 영상 엔티티를 관리하는 매니저입니다.
    let videoManager = VideoManager()

    /// # Overview
    /// 사용자가 저장한 클립을 관리하는 매니저입니다.
    let clipManager = ClipManager()

    // MARK: - Data Setup

    /// # Overview
    /// CoreData로부터 영상 목록을 불러오고 기본 정렬을 수행합니다.
    ///
    /// # Discussion
    /// - 앱 최초 실행 시 seed 데이터가 없는 경우 자동으로 생성합니다.
    /// - Swift 태그가 붙은 영상이 항상 목록 상단에 오도록 정렬합니다.
    func setupData() {
        videoManager.seedIfNeeded()

        videoList = videoManager.fetch()

        videoList.sort { alpha, beta in
            let aIsSwift = (alpha.tag == "Swift")
            let bIsSwift = (beta.tag == "Swift")

            if aIsSwift != bIsSwift { return aIsSwift }
            return (alpha.title ?? "") < (beta.title ?? "")
        }
    }

    // MARK: - UI Setup

    /// # Overview
    /// MainLayout 내부 요소들을 초기화하고 UI를 구성합니다.
    ///
    /// # Discussion
    /// - Header 설정
    /// - 언어 선택 메뉴 구성
    /// - 영상 리스트 구성
    /// - 프로그레스 슬라이더 설정
    /// - 볼륨 UI 구성
    /// 등 화면 구성에 필요한 모든 UI 초기화를 수행합니다.
    func setupUI() {
        mainView.setHeader()
        mainView.configureLanguageMenu()
        mainView.setTopVideo()
        mainView.setProgressSlider()
        mainView.setVideoButton()
        mainView.configureVideoSpeed()
        mainView.setVideoCollection()
        mainView.setBottomMenu()
        mainView.setSeachBar()
        mainView.setVolumeSlider()

        if let player = playerManager.player {
            mainView.playerView.player = player
            mainView.volumeSlider.value = player.volume
        }

        mainView.collectionView.reloadData()
    }

    // MARK: - Delegates

    /// # Overview
    /// UICollectionView 및 UISearchBar delegate를 설정합니다.
    ///
    /// # Discussion
    /// - 컬렉션뷰 셀 선택
    /// - 검색 입력
    /// 등의 이벤트 처리를 위해 delegate가 필요합니다.
    func setupDelegates() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.searchBar.delegate = self
    }

    // MARK: - Actions

    /// # Overview
    /// 화면 내 버튼 및 슬라이더 이벤트를 실제 함수와 연결합니다.
    ///
    /// # Discussion
    /// `addTarget(_:action:for:)`를 통해 UI와 로직을 연결하며,
    /// 영상 조작·검색·전체화면·볼륨 등 다양한 이벤트를 처리합니다.
    func setupActions() {
        mainView.searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        mainView.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        mainView.languageButton.addTarget(self, action: #selector(dropdownClick(_:)), for: .touchUpInside)
        mainView.saveToClipButton.addTarget(self, action: #selector(saveClipButtonClick(_:)), for: .touchUpInside)
        mainView.fullScreenButton.addTarget(self, action: #selector(goFullScreen(_:)), for: .touchUpInside)
        mainView.forward15sButton.addTarget(self, action: #selector(forward15sButtonTapped(_:)), for: .touchUpInside)
        mainView.rewind15sButton.addTarget(self, action: #selector(rewind15sButtonTapped(_:)), for: .touchUpInside)
        mainView.bottomSearchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        mainView.volumeButton.addTarget(self, action: #selector(volumeButtonClick(_:)), for: .touchUpInside)
        mainView.volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
        mainView.ellipsisButton.addTarget(self, action: #selector(ellipsButtonClick(_:)), for: .touchUpInside)
        mainView.clipButton.addTarget(self, action: #selector(pushMyClipScreen(_:)), for: .touchUpInside)
        mainView.tagButton.addTarget(self, action: #selector(pushTagScreen(_:)), for: .touchUpInside)
        mainView.settingButton.addTarget(self, action: #selector(pushSettingScreen(_:)), for: .touchUpInside)

        mainView.progressSlider.addTarget(self, action: #selector(scrubBegan(_:)), for: .touchDown)
        mainView.progressSlider.addTarget(self, action: #selector(scrubChanged(_:)), for: .valueChanged)
        mainView.progressSlider.addTarget(self, action: #selector(scrubEnded(_:)), for: .touchUpInside)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(progressSliderTapped(_:)))
        mainView.progressSlider.addGestureRecognizer(gesture)
    }

    // MARK: - Callbacks

    /// # Overview
    /// DropDown 메뉴와 PlayerManager의 콜백 함수를 설정합니다.
    ///
    /// # Discussion
    /// UI에서 선택된 언어/배속 등이 변경되면 callback을 통해
    /// 플레이어 또는 리스트 정렬 로직에 반영됩니다.
    func setupCallbacks() {

        mainView.onLanguageSelected = { [weak self] lang in
            self?.prioritizeLanguage(lang)
        }

        mainView.onSpeedSelected = { [weak self] speed in
            self?.playerManager.changeSpeed(to: speed)
        }

        playerManager.onVolumeChanged = { [weak self] volume in
            guard let self else { return }
            self.mainView.volumeSlider.value = volume
            self.mainView.volumeLabel.text = String(Int(volume * 100))
        }

        bindPlayerCallbacks()
    }

    /// # Overview
    /// PlayerManager의 재생 관련 콜백을 UI에 연결합니다.
    ///
    /// # Discussion
    /// - 재생 종료
    /// - 진행률 업데이트
    /// - 전체 길이 로드
    /// - 재생 상태 변경
    /// 등 플레이어 이벤트를 UI에 반영합니다.
    func bindPlayerCallbacks() {

        playerManager.onPlayEnded = { [weak self] in
            self?.handlePlayEnd()
        }

        playerManager.onProgressChanged = { [weak self] progress, currentText in
            self?.mainView.progressSlider.value = progress
            self?.mainView.start.text = currentText
        }

        playerManager.onDurationLoaded = { [weak self] durationText in
            self?.mainView.end.text = durationText
        }

        playerManager.onPlayStateChanged = { [weak self] isPlaying in
            guard let self else { return }

            let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            let symbolName = isPlaying ? "pause.fill" : "play.fill"

            self.mainView.playButton.setImage(
                UIImage(systemName: symbolName, withConfiguration: cfg),
                for: .normal
            )
        }
    }

    // MARK: - Video Sorting

    /// # Overview
    /// 지정된 언어 태그를 기준으로 영상 리스트를 재정렬합니다.
    ///
    /// # Discussion
    /// 선택된 언어와 일치하는 tag를 가진 영상이 상단에 오도록 정렬한 뒤,
    /// 컬렉션뷰를 갱신합니다.
    ///
    /// - Parameters:
    ///   - language: 선택된 언어 문자열
    func prioritizeLanguage(_ language: String) {
        videoList.sort { lhs, rhs in
            let lhsMatch = (lhs.tag == language)
            let rhsMatch = (rhs.tag == language)

            if lhsMatch == rhsMatch { return false }
            return lhsMatch && !rhsMatch
        }

        mainView.collectionView.reloadData()
    }

    // MARK: - Life Cycle

    override func loadView() {
        self.view = mainView
        view.backgroundColor = AppColor.background
    }

    /// # Overview
    /// 메인 화면 로딩 시 필요한 모든 초기화를 수행합니다.
    ///
    /// # Discussion
    /// - CoreData 데이터 로딩  
    /// - UI 구성  
    /// - Delegate 설정  
    /// - Target(Action) 연결  
    /// - Callback 설정  
    ///
    /// 모두 여기서 한 번에 호출됩니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupDelegates()
        setupActions()
        setupCallbacks()
    }

    // MARK: - Layout & Environment Updates

    /// # Overview
    /// 기기 회전 또는 화면 크기 변경 시 iPad 레이아웃을 업데이트합니다.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.mainView.updateForIpad(for: self.traitCollection, containerSize: size)
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.updateForIpad(for: traitCollection, containerSize: view.bounds.size)
    }

    /// # Overview
    /// 다크모드/라이트모드 및 환경 변화 시 UI를 갱신합니다.
    ///
    /// # Discussion
    /// 드롭다운 스타일, 푸터 스타일, 배경색 등을
    /// 현재 traitCollection에 맞게 업데이트합니다.
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.updateFooterView(for: traitCollection)
        mainView.langauageDropDown.reloadAllComponents()
        mainView.speedDropDown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }
}

#Preview() {
    UINavigationController(rootViewController: MainViewController())
}
