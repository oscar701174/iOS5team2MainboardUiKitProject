import Foundation
import UIKit
import AVFoundation
import DropDown
import MediaPlayer

/// # Overview
/// 메인 영상 재생 화면에서 사용되는 **전체 UI를 구성하는 핵심 레이아웃 뷰**입니다.
///
/// # Discussion
/// `MainViewController`의 `view`로 직접 사용되며,
/// 영상 재생, 언어 선택, 배속 조절, 볼륨 조절, 영상 리스트 등
/// 사용자 인터페이스의 모든 요소를 배치하고 스타일을 적용합니다.
///
/// 이 클래스는 다음과 같은 기능을 담당합니다:
/// - 상단 헤더(언어 버튼/검색 버튼) 구성
/// - 영상 플레이어(PlayerView) 배치
/// - 재생 관련 버튼(재생/일시정지, 15초 이동 등) 배치
/// - 볼륨 슬라이더 및 볼륨 팝업 UI 구성
/// - 배속 선택 DropDown, 언어 DropDown 스타일 및 위치 관리
/// - 영상 리스트(CollectionView) 배치
/// - iPad 대응 레이아웃(가로/세로)에 따른 제약 조건 전환
///
/// 복잡한 UI를 한 곳에서 관리하여 MainViewController의 코드 복잡도를 줄이는 역할을 합니다.
class MainLayout: UIView {

    // MARK: - Labels
    /// 재생 중인 영상의 현재 시간을 표시합니다.
    let start = UILabel()

    /// 영상의 총 재생 시간을 표시합니다.
    let end = UILabel()

    /// 볼륨 퍼센트 값을 표시합니다.
    let volumeLabel = UILabel()

    // MARK: - Buttons
    /// 언어 버튼에 사용되는 기본 이미지 (예비 이미지)
    let languageImage = UIImage()

    /// 언어 선택 메뉴 버튼입니다.
    let languageButton = UIButton()

    /// 검색창 표시/숨김 버튼입니다.
    let searchButton = UIButton()

    /// 전체 화면 전환 버튼입니다.
    let fullScreenButton = UIButton()

    /// 15초 앞으로 이동 버튼입니다.
    let forward15sButton = UIButton()

    /// 재생/일시정지 버튼입니다.
    let playButton = UIButton()

    /// 15초 뒤로 이동 버튼입니다.
    let rewind15sButton = UIButton()

    /// 볼륨 팝업 표시 버튼입니다.
    let volumeButton = UIButton()

    /// 배속 선택 DropDown 표시 버튼입니다.
    let ellipsisButton = UIButton()

    /// 태그 화면 이동 버튼입니다.
    let tagButton = UIButton()

    /// 클립 화면 이동 버튼입니다.
    let clipButton = UIButton()

    /// 설정 화면 이동 버튼입니다.
    let settingButton = UIButton()

    /// 하단 검색 버튼입니다.
    let bottomSearchButton = UIButton()

    /// 현재 재생 중 영상 클립 저장 버튼입니다.
    let saveToClipButton = UIButton()

    // MARK: - Views

    /// AVPlayerLayer를 표시하는 커스텀 PlayerView입니다.
    let playerView = PlayerView()

    /// 재생 관련 버튼들이 배치되는 스택뷰입니다.
    let middleButtonStackView = UIStackView()

    /// 하단 메뉴 버튼들이 배치되는 스택뷰입니다.
    let bottomButtonStackView = UIStackView()

    /// 영상 리스트를 표시하는 CollectionView입니다.
    var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    /// 볼륨 컨트롤 팝업 컨테이너 뷰입니다.
    let popup = UIView()

    /// 화면 하단 메뉴 바입니다.
    let bottomBarView = UIView()

    /// DropDown이 표시될 기준 뷰입니다.
    let dropView = UIView()

    // MARK: - Sliders
    /// 영상 재생 위치 이동 슬라이더입니다.
    let progressSlider = UISlider()

    /// 앱 내부 볼륨 조절 슬라이더입니다.
    let volumeSlider = UISlider()

    /// 시스템 볼륨을 제어하기 위한 MPVolumeView입니다.
    let systemVolumeView = MPVolumeView()

    // MARK: - Constraints
    var bottomToBottomMenu: NSLayoutConstraint!
    var bottomToKeyboard: NSLayoutConstraint!

    // MARK: - SearchBar
    /// 영상 검색을 위한 UISearchBar입니다.
    let searchBar = UISearchBar()

    // MARK: - DropDowns
    /// 언어 선택용 DropDown
    let langauageDropDown = DropDown()

    /// 배속 선택용 DropDown
    let speedDropDown = DropDown()

    // MARK: - Data
    let itemList = CategoryRepository.allCategories.map(\.name)

    // MARK: - Constraint Groups
    /// iPad 대응을 위해 레이아웃 그룹을 분리 관리합니다.
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
    /// 배속이 선택되었을 때 호출됩니다.
    var onSpeedSelected: ((Double) -> Void)?

    /// 언어가 선택되었을 때 호출됩니다.
    var onLanguageSelected: ((String) -> Void)?

    // MARK: - Symbol Configurations
    /// SF Symbol을 일관된 크기로 보여주기 위한 설정입니다.
    let cfg = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let forward15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
    let rewind15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let muteButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let ellipsisButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

    // MARK: - Layout Updates

    /// # Overview
    /// 서브뷰 레이아웃이 변경될 때마다 호출되어
    /// CollectionView 셀 크기와 DropDown 위치를 업데이트합니다.
    ///
    /// # Discussion
    /// - 기기 회전 등으로 CollectionView 너비가 변할 때
    ///   셀의 가로/세로 비율을 유지하도록 크기를 자동 조정합니다.
    ///
    /// - 언어 선택 DropDown은 언어 버튼 정중앙 아래에 자연스럽게 붙도록
    ///   위치를 계산하여 `bottomOffset`을 동적으로 업데이트합니다.
    override func layoutSubviews() {
        super.layoutSubviews()

        // 1) CollectionView 셀 자동 크기 조정
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width

            if flow.itemSize.width != width {
                flow.itemSize = CGSize(width: width, height: width * 0.68)
                flow.footerReferenceSize = CGSize(width: width, height: width * 0.12)
                flow.invalidateLayout()
            }
        }

        // 2) DropDown 위치 조정
        let anchor = languageButton

        langauageDropDown.width = max(160, anchor.bounds.width)
        langauageDropDown.direction = .bottom

        /// 버튼 너비가 좁을 경우에도 DropDown이 화면 밖으로 나가지 않도록
        /// x 좌표를 보정하기 위한 계산입니다.
        let cgX = max(0, anchor.bounds.width - max(160, anchor.bounds.width)) + 24

        langauageDropDown.bottomOffset = CGPoint(
            x: cgX,
            y: anchor.bounds.height
        )
    }
}

#Preview {
    MainViewController()
}

#Preview("iPad 가로", traits: .landscapeLeft) {
    MainViewController()
}
