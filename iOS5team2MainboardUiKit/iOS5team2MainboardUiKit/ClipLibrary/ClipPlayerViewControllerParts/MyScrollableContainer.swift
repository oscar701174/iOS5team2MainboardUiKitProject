import UIKit
import SwiftUI

//clip들을 포함하는 container
class MyScrollableContainer: UIScrollView {
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    var views: [UIView]
    var scrollMode: ScrollViewMode {
        didSet {
            updateCHCR()
            updateSizeConstraints()
            setNeedsLayout()
//            레이아웃 업데이트 요청
        }
    }
    
    init(contents: [UIView], scrollMode: ScrollViewMode){
        self.views = contents
        self.scrollMode = scrollMode
        super.init(frame: .zero)
        setup()
        updateSizeConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyScrollableContainer {
    func setup() {
        views.forEach {
            addSubview($0)
        }
    }
}

extension MyScrollableContainer {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        //        print(self,#function)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview( )
        //        print(self,#function)
    }
}

extension MyScrollableContainer {
    //subview위치 계산 배치
    override func layoutSubviews() {
        super.layoutSubviews()
        
        alwaysBounceHorizontal = scrollMode == .horizontal
        alwaysBounceVertical = scrollMode == .vertical
        
        let clip = views.first ?? UIView()
        let clipWidth = clip.intrinsicContentSize.width + 6
        let clipHeight = clip.intrinsicContentSize.height + 3
        let spacing: CGFloat = 10
        if scrollMode == .horizontal {
            let totalWidth = CGFloat(views.count) * (clipWidth + spacing)
            
            views.enumerated().forEach { index, content in
                let xPosition = CGFloat(index) * (clipWidth + spacing)
                content.frame = CGRect(x: xPosition, y: 0, width: clipWidth, height: clipHeight)
            }
            self.contentSize = CGSize(width: totalWidth, height: clipHeight)
        } else { // .vertical
            let totalHeight = CGFloat(views.count) * (clipHeight + spacing)
            
            views.enumerated().forEach { index, content in
                let yPosition = CGFloat(index) * (clipHeight + spacing)
                content.frame = CGRect(x: 0, y: yPosition, width: clipWidth, height: clipHeight)
            }
            
            self.contentSize = CGSize(width: clipWidth, height: totalHeight)
        }
    }
}

extension MyScrollableContainer {
    func updateCHCR() {
        if scrollMode == .vertical {
            // 세로 스크롤 모드:
            self.setContentCompressionResistancePriority(.required, for: .horizontal)
            self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            
            // Hugging(늘어나려는 성향)
            self.setContentHuggingPriority(.defaultLow, for: .horizontal)
            self.setContentHuggingPriority(.defaultHigh, for: .vertical)
            
        } else {
            // 가로 스크롤 모드:
            self.setContentCompressionResistancePriority(.required, for: .vertical)
            self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            // Hugging
            self.setContentHuggingPriority(.defaultLow, for: .vertical)
            self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
    }
    
    func updateSizeConstraints(itemWidth: CGFloat = 100, itemHeight: CGFloat = 50) {
        // 기존 제약 제거
        heightConstraint?.isActive = false
        widthConstraint?.isActive = false
        
        if scrollMode == .horizontal {
            // 높이를 itemHeight로 고정
            heightConstraint = self.heightAnchor.constraint(equalToConstant: itemHeight)
            heightConstraint?.isActive = true
            
        } else { // vertical
            
            widthConstraint = self.widthAnchor.constraint(equalToConstant: itemWidth)
            widthConstraint?.isActive = true
            
            
        }
    }
}

enum ScrollViewMode {
    case vertical
    case horizontal
}

#Preview {
    let view1: UIView = {
        let redView = UIView()
        redView.backgroundColor = .systemRed
        return redView
    }()
    
    let view2: UIView = {
        let blueView = UIView()
        blueView.backgroundColor = .systemBlue
        return blueView
    }()
    
    let view3: UIView = {
        let greenView = UIView()
        greenView.backgroundColor = .systemGreen
        return greenView
    }()
    
    MyScrollableContainer(contents: [view1, view2, view3], scrollMode: .vertical)
}
