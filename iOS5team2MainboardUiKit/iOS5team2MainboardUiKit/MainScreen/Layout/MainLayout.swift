import Foundation
import UIKit
import AVFoundation
import DropDown
import MediaPlayer

/// # Overview
/// 메인 화면의 모든 UI 구성을 담당하는 레이아웃 뷰입니다.
///
/// # Discussion
/// 이 클래스는 영상 재생 화면을 구성하기 위한 핵심 UI 요소들을 포함하고 있으며,
/// 다음과 같은 작업을 수행합니다:
/// - 상단 언어/검색 버튼 UI 구성  
/// - 영상 플레이어(PlayerView) 배치  
/// - 재생 관련 버튼(재생/일시정지, 15초 앞으로/뒤로 이동 등) 배치  
/// - 볼륨 조절 UI 및 팝업 구성  
/// - 영상 리스트를 보여주는 UICollectionView 배치  
/// - iPad 레이아웃 대응을 위한 다양한 제약 조건 관리  
///
/// 또한, 언어 선택 DropDown, 배속 DropDown 등 사용자가 직접 선택할 수 있는
/// 인터랙션 요소의 스타일도 포함합니다.
class MainLayout: UIView {

    // MARK: - Labels

    /// 영상 재생 시간(현재 위치)을 표시하는 라벨입니다.
    let start = UILabel()

    /// 영상의 총 재생 시간을 표시하는 라벨입니다.
    let end = UILabel()

    /// 볼륨 슬라이더의 현재 값을 퍼센트로 표시합니다.
    let volumeLabel = UILabel()

    // MARK: - Buttons

    let languageImage = UIImage()

    /// 언어 선택 메뉴를 여는 버튼입니다.
    let languageButton = UIButton()

    /// 검색창 표시/숨김을 전환하는 버튼입니다.
    let searchButton = UIButton()

    /// 전체 화면 전환 버튼입니다.
    let fullScreenButton = UIButton()

    /// 15초 앞으로 이동하는 버튼입니다.
    let forward15sButton = UIButton()

    /// 재생/일시정지 버튼입니다.
    let playButton = UIButton()

    /// 15초 뒤로 이동하는 버튼입니다.
    let rewind15sButton = UIButton()

    /// 볼륨 팝업을 여는 버튼입니다.
    let volumeButton = UIButton()

    /// 배속 DropDown을 여는 버튼입니다.
    let ellipsisButton = UIButton()

    /// 태그 화면 이동 버튼입니다.
    let tagButton = UIButton()

    /// 클립 화면 이동 버튼입니다.
    let clipButton = UIButton()

    /// 설정 화면 이동 버튼입니다.
    let settingButton = UIButton()

    /// 하단 검색 버튼입니다.
    let bottomSearchButton = UIButton()

    /// 현재 영상 클립 저장 버튼입니다.
    let saveToClipButton = UIButton()

    // MARK: - Views

    /// 영상 재생을 위한 AVPlayerLayer를 포함한 커스텀 뷰입니다.
    let playerView = PlayerView()

    /// 재생 관련 컨트롤 버튼들이 배치되는 스택뷰입니다.
    let middleButtonStackView = UIStackView()

    /// 하단 메뉴 버튼들이 배치되는 스택뷰입니다.
    let bottomButtonStackView = UIStackView()

    /// 영상 목록을 표시하는 CollectionView입니다.
    var collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout())

    /// 볼륨 팝업 컨테이너 뷰입니다.
    let popup = UIView()

    /// 화면 최하단의 메뉴 바 뷰입니다.
    let bottomBarView = UIView()

    /// DropDown이 표시될 대상 뷰입니다.
    let dropView = UIView()

    // MARK: - Sliders

    /// 영상 재생 위치를 나타내고 이동할 수 있게 하는 슬라이더입니다.
    let progressSlider = UISlider()

    /// 앱 내에서 사용하는 볼륨 조절 슬라이더입니다.
    let volumeSlider = UISlider()

    /// 시스템 볼륨 조절을 위해 내부적으로 사용하는 MPVolumeView입니다.
    let systemVolumeView = MPVolumeView()

    // MARK: - Constraints

    var bottomToBottomMenu: NSLayoutConstraint!
    var bottomToKeyboard: NSLayoutConstraint!

    // MARK: - SearchBar

    /// 검색 기능을 위한 UISearchBar입니다.
    let searchBar = UISearchBar()

    // MARK: - DropDowns

    /// 언어 선택 드롭다운
    let langauageDropDown = DropDown()

    /// 배속 선택 드롭다운
    let speedDropDown = DropDown()

    // MARK: - Data

    /// 카테고리 목록(문자열 배열)
    let itemList = CategoryRepository.allCategories.map(\.name)

    // MARK: - Layout Constraint Groups

    var headerDefaultConstriants: [NSLayoutConstraint] = []
    var headerIPadLandscapeConstriants: [NSLayoutConstraint] = []
    var topVideoDefaultConstraints: [NSLayoutConstraint] = []
    var topVideoIPadLandscapeConstraints: [NSLayoutConstraint] = []
    var progressSliderDefaultConstraints: [NSLayoutConstraint] = []
    var progressSliderIPadLandscapeConstraints: [NSLayoutConstraint] = []
    var videoButtonDefaultConstraints: [NSLayoutConstraint] = []
    var videoButtonIPadLandscapeConstraints: [NSLayoutConstraint] = []
    var videoCollectionDefaultConstraints: [NSLayoutConstraint] = []
    var videoCollectionIPadLandscapeConstraints: [NSLayoutConstraint] = []
    var bottomMenuDefaultConstrains: [NSLayoutConstraint] = []
    var bottomMenuIPadLandscapeConstraints: [NSLayoutConstraint] = []

    // MARK: - Callbacks

    /// 배속 변경 시 전달되는 콜백입니다.
    var onSpeedSelected: ((Double) -> Void)?

    /// 언어 변경 시 전달되는 콜백입니다.
    var onLanguageSelected: ((String) -> Void)?

    // MARK: - Symbol Configurations

    /// SF Symbol 크기를 통일적으로 설정하기 위한 구성 객체입니다.
    let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let forward15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
    let rewind15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let muteButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let ellipsisButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

    // MARK: - Layout Updates

    /// # Overview
    /// 서브뷰의 사이즈가 변경될 때마다 호출되며,
    /// 컬렉션뷰 셀 크기와 드롭다운 UI 위치를 업데이트합니다.
    ///
    /// # Discussion
    /// - 기기 회전 시 자동으로 셀 크기가 맞춰지도록 처리합니다.
    /// - 언어 선택 DropDown이 버튼 아래에 자연스럽게 붙도록 위치를 조정합니다.
    override func layoutSubviews() {
        super.layoutSubviews()

        // CollectionView 셀 자동 리사이징
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width

            if flow.itemSize.width != width {
                flow.itemSize = CGSize(width: width, height: width * 0.68)
                flow.footerReferenceSize = CGSize(width: width, height: width * 0.12)
                flow.invalidateLayout()
            }
        }

        // DropDown 위치 설정
        let anchor = languageButton

        langauageDropDown.width = max(160, anchor.bounds.width)
        langauageDropDown.direction = .bottom

        let cgX = max(0, anchor.bounds.width - max(160, anchor.bounds.width)) + 24
        langauageDropDown.bottomOffset = CGPoint(x: cgX, y: anchor.bounds.height)
    }
}

#Preview {
    MainViewController()
}

#Preview("iPad 가로", traits: .landscapeLeft) {
    MainViewController()
}
