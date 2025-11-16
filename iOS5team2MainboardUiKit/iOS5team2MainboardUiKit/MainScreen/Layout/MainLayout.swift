import Foundation
import UIKit
import AVFoundation
import DropDown
import MediaPlayer

class MainLayout: UIView {

    let start = UILabel()
    let end = UILabel()
    let volumeLabel = UILabel()

    let languageImage = UIImage()

    let languageButton = UIButton()
    let searchButton = UIButton()
    let fullScreenButton = UIButton()
    let forward15sButton = UIButton()
    let playButton = UIButton()
    let rewind15sButton = UIButton()
    let muteButton = UIButton()
    let ellipsisButton = UIButton()
    let tagButton = UIButton()
    let clipButton = UIButton()
    let settingButton = UIButton()
    let bottomSearchButton = UIButton()

    let playerView = PlayerView()
    let middleButtonStackView = UIStackView()
    let bottomButtonStackView = UIStackView()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let popup = UIView()
    let bottomBarView = UIView()
    let dropView = UIView()

    let progressSlider = UISlider()
    let volumeSlider = UISlider()

    let systemVolumeView = MPVolumeView()

    var bottomToBottomMenu: NSLayoutConstraint!
    var bottomToKeyboard: NSLayoutConstraint!

    let searchBar = UISearchBar()

    let langauageDropDown = DropDown()
    let speedDropDown = DropDown()

    let itemList = CategoryRepository.allCategories.map(\.name)

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

    var onSpeedSelected: ((Double) -> Void)?
    var onLanguageSelected: ((String) -> Void)?

    let forward15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
    let rewind15sButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let muteButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
    let ellipsisButtonCFG = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)

    override func layoutSubviews() {
        super.layoutSubviews()
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width
            if flow.itemSize.width != width {
                flow.itemSize = CGSize(width: width, height: width * 0.68)
                flow.footerReferenceSize = CGSize(width: width, height: width * 0.12)
                flow.invalidateLayout()
            }
        }

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
