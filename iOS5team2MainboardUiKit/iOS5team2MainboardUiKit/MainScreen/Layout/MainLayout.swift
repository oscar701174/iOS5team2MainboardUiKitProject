import Foundation
import UIKit
import AVFoundation
import DropDown

class MainLayout: UIView {

    let start = UILabel()
    let end = UILabel()

    let languageImage = UIImage()

    let languageButton = UIButton()
    let searchButton = UIButton()
    let fullScreenButton = UIButton()
    let forward15sButton = UIButton()
    let playButton = UIButton()
    let rewind15sButton = UIButton()
    let airPlayButton = UIButton()
    let ellipsisButton = UIButton()
    let tagButton = UIButton()
    let clipButton = UIButton()
    let settingButton = UIButton()
    let bottomSearchButton = UIButton()

    let playerView = PlayerView()
    let middleButtonStackView = UIStackView()
    let bottomButtonStackView = UIStackView()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let bottomBarView = UIView()
    let dropView = UIView()

    let progressSlider = UISlider()

    var bottomToBottomMenu: NSLayoutConstraint!
    var bottomToKeyboard: NSLayoutConstraint!

    let searchBar = UISearchBar()
    let dropdown = DropDown()
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
    var  bottomMenuIPadLandscapeConstraints: [NSLayoutConstraint] = []

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
        dropdown.width = max(160, anchor.bounds.width)
        dropdown.direction = .bottom

        let cgX = max(0, anchor.bounds.width - max(160, anchor.bounds.width)) + 24
        dropdown.bottomOffset = CGPoint(x: cgX, y: anchor.bounds.height)
    }

}

#Preview {
    MainViewController()
}

#Preview("iPad 가로", traits: .landscapeLeft) {
    MainViewController()
}
