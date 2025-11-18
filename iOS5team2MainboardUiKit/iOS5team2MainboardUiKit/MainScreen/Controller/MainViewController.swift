import UIKit
import AVFoundation
import DropDown
import CoreData

/// # Overview
/// 메인 영상 재생 화면을 담당하는 ViewController입니다.
///
/// 이 화면은 다음과 같은 핵심 기능을 제공합니다:
/// - 전체 UI 구성(MainLayout)
/// - 영상 재생/일시정지, 배속, 슬라이더 이동, 전체화면 전환 등 AVPlayer 조작
/// - CoreData 기반 영상 목록 불러오기 및 정렬(VideoManager)
/// - 검색, 언어 변경, 클립 저장 등 사용자 상호작용 처리
///
/// # Discussion
/// 이 컨트롤러는 “화면에서 발생하는 모든 사용자 입력”을 관리하고,
/// 실제 영상 재생 동작은 `VideoPlayerManager`에 위임합니다.
///
/// 즉,
/// - **MainViewController → UI·상태·이벤트 관리**
/// - **VideoPlayerManager → 영상 재생 로직 관리**
///
/// 역할이 분리되어 있어 유지보수와 확장이 용이한 구조입니다.
///
/// 또한, 언어 태그 정렬, 영상 목록 갱신, 슬라이더 이동 등
/// 화면과 데이터 사이의 연결을 담당하는 허브 역할을 합니다.
///
/// - Note:
///   컬렉션뷰(영상 리스트)와 검색 기능을 제공하기 위해
///   `UICollectionViewDelegate`, `UICollectionViewDataSource`, `UISearchBarDelegate`를 함께 구현합니다.
class MainViewController: UIViewController {

    // MARK: - State Flags
    // 화면 상태 관리에 필요한 다양한 플래그들입니다.

    /// 검색 UI(SearchBar)의 활성화 여부입니다.
    var isSearchButtonActive = true

    /// AVPlayer의 시간 진행 상태를 관찰하기 위한 객체입니다.
    var timeObserver: Any?

    /// 영상이 끝까지 재생되었는지 여부입니다.
    var didReachEnd = false

    /// 사용자가 슬라이더를 조작 중인지 여부입니다.
    var isScrubbing = false

    /// 슬라이더 조작 시작 직전 영상이 재생 중이었는지 저장합니다.
    var wasPlayingBeforeScrub = false

    /// 전체화면 진입 직전 영상 재생 여부를 기록합니다.
    var wasPlayingBeforeFullScreen = false

    /// 검색 모드 활성화 여부입니다.
    var isSearching = false

    /// 현재 재생 중인 영상의 URL입니다.
    var playingVideoURL: URL?

    /// 선택된 영상 엔티티입니다.
    /// 클립 저장 등 후속 작업에 필요합니다.
    var selectedVideo: VideoEntity?

    // MARK: - View & Managers

    /// 화면 UI 전체를 담고 있는 MainLayout 인스턴스입니다.
    let mainView = MainLayout()

    /// AVPlayer 관련 기능(재생, 일시정지, 배속, 전체화면 등)을 담당하는 매니저입니다.
    let playerManager = VideoPlayerManager()

    /// CoreData에서 불러온 전체 영상 목록입니다.
    var videoList: [VideoEntity] = []

    /// 검색 결과를 담는 배열입니다.
    var filteredVideos: [VideoEntity] = []

    /// CoreData 기반 영상 데이터를 관리하는 매니저입니다.
    let videoManager = VideoManager()

    /// 사용자가 저장한 클립 데이터를 관리하는 매니저입니다.
    let clipManager = ClipManager()


    // MARK: - Data Setup

    /// # Overview
    /// CoreData에서 영상 목록을 불러오고 초기 데이터를 준비합니다.
    ///
    /// # Discussion
    /// - 앱 첫 실행 시 기본 영상 데이터를 자동으로 생성합니다.
    /// - 저장된 데이터를 불러와 `videoList`에 저장합니다.
    ///
    /// 이 함수는 화면이 로드될 때 가장 먼저 호출됩니다.
    func setupData() {
        videoManager.seedIfNeeded()
        videoList = videoManager.fetch()

    }


    // MARK: - UI Setup

    /// # Overview
    /// 메인 화면을 구성하는 모든 UI 요소를 초기화합니다.
    ///
    /// # Discussion
    /// - 헤더 구성
    /// - 언어/배속 드롭다운
    /// - 영상 리스트(CollectionView) 설정
    /// - 플레이어 뷰, 슬라이더, 버튼 구성
    /// - 볼륨 UI 연결
    ///
    /// MainLayout이 제공하는 여러 구성 함수를 호출해 전체 화면을 완성합니다.
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
        }

        mainView.collectionView.reloadData()
    }


    // MARK: - Delegates

    /// # Overview
    /// UICollectionView 및 UISearchBar의 delegate를 구성합니다.
    ///
    /// # Discussion
    /// 영상 리스트 표시, 셀 선택, 검색어 입력 등에 대한 처리를 위해 필요합니다.
    func setupDelegates() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.searchBar.delegate = self
    }


    // MARK: - Actions

    /// # Overview
    /// 화면의 모든 버튼·슬라이더 등 UI 이벤트를 기능 함수와 연결합니다.
    ///
    /// # Discussion
    /// Target-Action 패턴을 통해
    /// “사용자 입력 → 실제 동작 실행” 과정이 연결됩니다.
    ///
    /// 예:
    /// - 재생 버튼 탭 → `playButtonTapped` 실행
    /// - 전체화면 버튼 탭 → `goFullScreen` 실행
    /// - 슬라이더 조작 → 영상 위치 변경
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
    /// DropDown 메뉴와 PlayerManager의 콜백을 화면(UI)과 연결합니다.
    ///
    /// # Discussion
    /// - 언어 변경 → 영상 리스트 재정렬
    /// - 배속 변경 → Player 속도 조정
    /// - 볼륨 변경 → UI 표시값 갱신
    ///
    /// 플레이어의 진행률, 상태 변화 등도 UI에 즉시 반영되도록 설정합니다.
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
    /// PlayerManager가 전달하는 영상품질·위치·상태 변화를 UI에 업데이트합니다.
    ///
    /// # Discussion
    /// - 재생 종료 → 다음 행동 처리
    /// - 영상 진행률 변경 → 슬라이더 업데이트
    /// - 영상 길이 로드 완료 → 총 재생 시간 표시
    /// - 재생/일시정지 상태 → 버튼 아이콘 변경
    func bindPlayerCallbacks() {

        playerManager.onPlayEnded = { [weak self] in
            self?.handlePlayEnd()
        }

        playerManager.onProgressChanged = { [weak self] progress, currentTime in
            self?.mainView.progressSlider.value = progress
            self?.mainView.start.text = currentTime
        }

        playerManager.onDurationLoaded = { [weak self] duration in
            self?.mainView.end.text = duration
        }

        playerManager.onPlayStateChanged = { [weak self] isPlaying in
            guard let self else { return }

            if isPlaying, let tag = self.selectedVideo?.tag, !tag.isEmpty {
                WeightStore.shared.add(1, to: tag)
            }

            let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            let icon = isPlaying ? "pause.fill" : "play.fill"

            self.mainView.playButton.setImage(
                UIImage(systemName: icon, withConfiguration: cfg),
                for: .normal
            )
        }
    }


    // MARK: - Video Sorting

    /// # Overview
    /// 선택한 언어 태그를 기준으로 영상 목록을 다시 정렬합니다.
    ///
    /// # Discussion
    /// - 사용자가 클릭한 언어 태그를 목록 최상단으로 배치합니다.
    /// - `WeightStore`를 활용하여 “선호도 높은 태그”가 더 앞에 오도록 합니다.
    ///
    /// # Parameters
    /// - language: 사용자가 선택한 언어 태그입니다.
    func prioritizeLanguage(_ language: String) {
        let tags = Array(Set(videoList.compactMap { $0.tag }))

        var orderedTags = WeightStore.shared.sortedLanguages(from: tags)

        if language != "전체" {
            if let idx = orderedTags.firstIndex(of: language) {
                orderedTags.remove(at: idx)
            }
            orderedTags.insert(language, at: 0)
        }

        let priority = Dictionary(uniqueKeysWithValues: orderedTags.enumerated().map { ($1, $0) })

        videoList.sort { lhs, rhs in
            let lp = priority[lhs.tag ?? ""] ?? Int.max
            let rp = priority[rhs.tag ?? ""] ?? Int.max
            if lp != rp { return lp < rp }
            return (lhs.title ?? "") < (rhs.title ?? "")
        }

        mainView.collectionView.reloadData()
    }


    // MARK: - Life Cycle

    override func loadView() {
        self.view = mainView
        view.backgroundColor = AppColor.background
    }

    /// # Overview
    /// 화면 로드 시 필요한 모든 초기 작업을 실행합니다.
    ///
    /// # Discussion
    /// 이 시점에 다음을 모두 처리합니다:
    /// - 데이터 불러오기
    /// - UI 구성
    /// - delegate 연결
    /// - 이벤트 연결
    /// - 콜백 설정
    /// - 기본 언어 정렬 적용
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupDelegates()
        setupActions()
        setupCallbacks()
        prioritizeLanguage("전체")

    }


    // MARK: - Layout & Environment

    /// # Overview
    /// 화면 회전 또는 크기 변경 시 레이아웃을 갱신합니다.
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
    /// 라이트/다크모드 등 환경 변화에 따라 UI 표시를 업데이트합니다.
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
