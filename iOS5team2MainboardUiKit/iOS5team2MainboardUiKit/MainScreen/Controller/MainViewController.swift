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
/// - MainViewController → UI·상태·이벤트 관리
/// - VideoPlayerManager → 영상 재생 로직 관리
///
/// 또한, 언어 태그 정렬, 영상 목록 갱신, 슬라이더 이동 등
/// 화면과 데이터 사이의 연결을 담당하는 허브 역할을 합니다.
///
/// - Note:
///   컬렉션뷰(영상 리스트)와 검색 기능을 제공하기 위해
///   `UICollectionViewDelegate`, `UICollectionViewDataSource`, `UISearchBarDelegate`를 함께 구현합니다.
class MainViewController: UIViewController {

    // MARK: - State Flags

    /// 검색 UI(SearchBar) 표시/숨김 상태를 관리합니다.
    var isSearchButtonActive = true

    /// AVPlayer의 주기적 시간 업데이트 옵저버 토큰입니다.
    var timeObserver: Any?

    /// 현재 아이템이 끝까지 재생되었는지 여부입니다.
    var didReachEnd = false

    /// 사용자가 진행 슬라이더를 조작 중인지 여부입니다.
    var isScrubbing = false

    /// 슬라이더 조작 시작 직전 재생 상태를 저장합니다.
    var wasPlayingBeforeScrub = false

    /// 전체화면 진입 직전 재생 상태를 저장합니다.
    var wasPlayingBeforeFullScreen = false

    /// 검색 모드 활성화 여부입니다.
    var isSearching = false

    /// 현재 재생 중인 영상의 URL입니다.
    var playingVideoURL: URL?

    /// 현재 선택된 영상 엔티티입니다. (클립 저장 등에 사용)
    var selectedVideo: VideoEntity?

    // MARK: - View & Managers

    /// 메인 화면 전체 UI를 담당하는 레이아웃 뷰
    let mainView = MainLayout()

    /// AVPlayer 제어(재생/일시정지/배속/전체화면 등)를 담당하는 매니저
    let playerManager = VideoPlayerManager()

    /// CoreData에서 불러온 전체 영상 목록
    var videoList: [VideoEntity] = []

    /// 검색 결과 목록(필요 시 사용)
    var filteredVideos: [VideoEntity] = []

    /// CoreData 영상 CRUD 매니저
    let videoManager = VideoManager()

    /// CoreData 클립 CRUD 매니저
    let clipManager = ClipManager()

    // MARK: - Data Setup

    /// # Overview
    /// CoreData에서 영상 목록을 불러오고, 메인 화면에서 사용할 데이터로 정제합니다.
    ///
    /// # Discussion
    /// - 앱 최초 실행 시 seed 데이터를 주입합니다.
    /// - Main 화면에서는 "로컬(사용자 문서 파일)"로 추가된 항목(file://)은 제외합니다.
    ///
    /// - Note:
    ///   사용자가 파일로 추가한 로컬 영상은 별도의 “내 클립/내 영상” 화면에서 관리하도록 하고,
    ///   메인 화면은 샘플/원격/번들 기반 목록만 보여주도록 설계했습니다.
    func setupData() {
        videoManager.seedIfNeeded()
        var fetched = videoManager.fetch()

        // 메인 화면에서는 "로컬(사용자 문서 파일)"로 추가된 항목을 제외한다.
        // 기준: url이 "file://" 로 시작하면 로컬로 간주.
        fetched.removeAll { entity in
            guard let urlString = entity.url else { return false }
            return urlString.lowercased().hasPrefix("file://")
        }

        videoList = fetched
    }

    // MARK: - UI Setup

    /// # Overview
    /// 메인 화면의 모든 UI 요소를 초기화하고 배치합니다.
    ///
    /// # Discussion
    /// - 헤더(언어 버튼/검색 버튼)
    /// - 플레이어 뷰 및 컨트롤(슬라이더/버튼)
    /// - 배속 드롭다운, 언어 드롭다운
    /// - 영상 리스트(CollectionView)
    /// - 하단 메뉴 바
    /// - 볼륨 UI
    ///
    /// - Note:
    ///   `MainLayout`의 구성 메서드를 호출하여 화면을 완성합니다.
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
    /// UICollectionView 및 UISearchBar의 delegate/dataSource를 연결합니다.
    func setupDelegates() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.searchBar.delegate = self
    }

    // MARK: - Actions

    /// # Overview
    /// UI 컨트롤들(버튼/슬라이더)의 Target-Action을 등록합니다.
    ///
    /// # Discussion
    /// - 검색 버튼 → 검색바 토글
    /// - 재생/일시정지/앞뒤로 이동/전체화면 → 플레이어 제어
    /// - 슬라이더 조작 → 현재 재생 위치 이동
    /// - 언어 버튼 → 드롭다운 표시
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
    /// MainLayout과 VideoPlayerManager의 콜백을 바인딩합니다.
    ///
    /// # Discussion
    /// - 언어 선택 콜백 → 리스트 정렬(prioritizeLanguage)
    /// - 배속 선택 콜백 → 플레이어 속도 변경
    /// - 볼륨 변경 콜백 → 볼륨 UI 동기화
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
    /// 플레이어 진행률/길이/상태 변화 콜백을 UI에 반영합니다.
    ///
    /// # Discussion
    /// - onPlayEnded: 재생 종료 처리
    /// - onProgressChanged: 슬라이더/현재시간 갱신
    /// - onDurationLoaded: 총 길이 표시
    /// - onPlayStateChanged: 재생/일시정지 아이콘 변경 및 가중치 업데이트
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
    /// 선택한 언어를 우선순위로 두고 영상 리스트를 정렬합니다.
    ///
    /// # Parameters
    /// - language: 선택된 언어(또는 "전체")
    ///
    /// # Discussion
    /// 사용자 선호도 가중치(WeightStore)를 반영하여 태그 우선순위를 계산하고,
    /// 동일 우선순위일 경우 제목 알파벳 순으로 정렬합니다.
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

    /// # Overview
    /// view를 MainLayout으로 교체하고 기본 배경색을 설정합니다.
    override func loadView() {
        self.view = mainView
        view.backgroundColor = AppColor.background
    }

    /// # Overview
    /// 초기 데이터/UI/이벤트/콜백을 설정하고 기본 정렬을 적용합니다.
    ///
    /// # Discussion
    /// - customTagsDidUpdate 노티를 구독하여 언어 드롭다운을 즉시 갱신합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupDelegates()
        setupActions()
        setupCallbacks()
        prioritizeLanguage("전체")

        NotificationCenter.default.addObserver(
            forName: .customTagsDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            // 열려있을 수 있는 드롭다운을 우선 닫고
            self.mainView.langauageDropDown.hide()
            // 드롭다운 데이터소스 갱신 + 즉시 리로드 보장
            self.mainView.updateLanguageMenuItems()
            self.mainView.langauageDropDown.reloadAllComponents()
            self.mainView.languageButton.layoutIfNeeded()
            // 필요 시 정렬 재적용
            self.prioritizeLanguage("전체")
        }
    }

    // MARK: - Layout & Environment

    /// # Overview
    /// 화면 회전/크기 변경 시 iPad 전용 레이아웃 전환을 트리거합니다.
    ///
    /// - Parameters:
    ///   - size: 변경될 크기
    ///   - coordinator: 전환 애니메이션 코디네이터
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.mainView.updateForIpad(for: self.traitCollection, containerSize: size)
        })
    }

    /// # Overview
    /// 서브뷰 레이아웃 완료 후 iPad 레이아웃을 재평가합니다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.updateForIpad(for: traitCollection, containerSize: view.bounds.size)
    }
    

    /// # Overview
    /// 라이트/다크모드 등 환경 변화에 따라 DropDown/버튼/푸터 색상을 갱신합니다.
    ///
    /// - Parameters:
    ///   - previous: 이전 traitCollection
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        mainView.updateDropdownColors(for: traitCollection)
        mainView.updateFooterView(for: traitCollection)
        mainView.updateButtonColors(for: traitCollection)
        mainView.langauageDropDown.reloadAllComponents()
        mainView.speedDropDown.reloadAllComponents()
        view.backgroundColor = AppColor.background
    }

    /// # Overview
    /// 지원하는 화면 회전 방향을 기기 종류에 따라 다르게 지정합니다.
    ///
    /// # Discussion
    /// - iPhone: 세로(Portrait)만 허용
    /// - iPad: 모든 방향(.all) 허용
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait       // iPhone은 세로 고정
        } else {
            return .all            // iPad는 자유롭게 회전
        }
    }

    /// # Overview
    /// 기본 표시 방향을 지정합니다. (Portrait)
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    /// # Overview
    /// 자동 회전(Autorotate) 허용 여부를 기기별로 지정합니다.
    ///
    /// # Discussion
    /// - iPhone: 회전 금지 (false)
    /// - iPad: 회전 허용 (true)
    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
        // iPhone일 땐 회전 금지
    }

}


#Preview() {
    UINavigationController(rootViewController: MainViewController())
}
