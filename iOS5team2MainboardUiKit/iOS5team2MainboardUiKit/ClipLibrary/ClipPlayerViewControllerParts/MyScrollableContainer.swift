import UIKit
import SwiftUI

/// # MyScrollableContainer
/// clip 버튼들을 가로 또는 세로 스크롤로 보여주는 커스텀 UIScrollView
/// - 스크롤 방향에 따라 Hugging/Compression 설정 및 사이즈 제약을 동적으로 조절.
/// - ClipPlayerViewController에서 clip 버튼들을 표시할 때 사용됨.
class MyScrollableContainer: UIScrollView {

    // MARK: - 내부 상태 변수

    /// 동적으로 설정되는 높이 제약
    private var heightConstraint: NSLayoutConstraint?

    /// 동적으로 설정되는 너비 제약
    private var widthConstraint: NSLayoutConstraint?

    /// 내부에 표시할 view 배열 (clip 버튼들)
    var views: [UIView]

    /// 스크롤 방향 (.vertical / .horizontal)
    var scrollMode: ScrollViewMode {
        didSet {
            updateCHCR()               // Hugging/Compression 조정
            updateSizeConstraints()    // 사이즈 제약 조정
            setNeedsLayout()           // 레이아웃 업데이트 요청
        }
    }

    // MARK: - 초기화

    /// 사용자 정의 initializer
    /// - Parameters:
    ///   - contents: 스크롤뷰에 표시할 버튼/뷰 배열
    ///   - scrollMode: 스크롤 방향
    init(contents: [UIView], scrollMode: ScrollViewMode) {
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

// MARK: - 초기 setup 영역

extension MyScrollableContainer {

    /// 스크롤뷰에 view들을 addSubview로 추가
    func setup() {
        views.forEach { addSubview($0) }
    }
}

// MARK: - (옵션) Lifecycle Hooks — 디버깅용

extension MyScrollableContainer {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // print(self, #function)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // print(self, #function)
    }
}

// MARK: - 레이아웃 계산

extension MyScrollableContainer {

    /// 서브뷰 위치 자동 배치 (scrollMode에 따라 방향 조절)
    override func layoutSubviews() {
        super.layoutSubviews()

        // 스크롤 모드에 따라 bounce 방향 설정
        alwaysBounceHorizontal = scrollMode == .horizontal
        alwaysBounceVertical = scrollMode == .vertical

        // 기준 크기를 측정하기 위해 첫 번째 뷰의 intrinsic 크기 사용
        let clip = views.first ?? UIView()
        let clipWidth = clip.intrinsicContentSize.width + 6
        let clipHeight = clip.intrinsicContentSize.height + 3
        let spacing: CGFloat = 10

        if scrollMode == .horizontal {
            // 가로 스크롤일 때: X축으로 나열
            let totalWidth = CGFloat(views.count) * (clipWidth + spacing)

            views.enumerated().forEach { index, content in
                let xPosition = CGFloat(index) * (clipWidth + spacing)
                content.frame = CGRect(x: xPosition, y: 0, width: clipWidth, height: clipHeight)
            }

            contentSize = CGSize(width: totalWidth, height: clipHeight)

        } else {
            // 세로 스크롤일 때: Y축으로 나열
            let totalHeight = CGFloat(views.count) * (clipHeight + spacing)

            views.enumerated().forEach { index, content in
                let yPosition = CGFloat(index) * (clipHeight + spacing)
                content.frame = CGRect(x: 0, y: yPosition, width: clipWidth, height: clipHeight)
            }

            contentSize = CGSize(width: clipWidth, height: totalHeight)
        }
    }
}

// MARK: - 우선순위 & 사이즈 제약 조정

extension MyScrollableContainer {

    /// Hugging / Compression Resistance 설정 업데이트
    func updateCHCR() {
        if scrollMode == .vertical {
            // 세로 스크롤:
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentHuggingPriority(.defaultHigh, for: .vertical)

        } else {
            // 가로 스크롤:
            setContentCompressionResistancePriority(.required, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
    }

    /// scrollMode에 따라 width 또는 height를 고정하는 제약 추가
    func updateSizeConstraints(itemWidth: CGFloat = 100, itemHeight: CGFloat = 50) {

        // 기존 제약 제거
        heightConstraint?.isActive = false
        widthConstraint?.isActive = false

        if scrollMode == .horizontal {
            // 가로 스크롤 → 높이 고정
            heightConstraint = heightAnchor.constraint(equalToConstant: itemHeight)
            heightConstraint?.isActive = true

        } else {
            // 세로 스크롤 → 너비 고정
            widthConstraint = widthAnchor.constraint(equalToConstant: itemWidth)
            widthConstraint?.isActive = true
        }
    }
}

// MARK: - 스크롤 방향 Enum

/// 스크롤뷰 방향 (vertical: 세로, horizontal: 가로)
enum ScrollViewMode {
    case vertical
    case horizontal
}

// MARK: - SwiftUI Preview

#Preview {
    let view1: UIView = {
        let v = UIView()
        v.backgroundColor = .systemRed
        return v
    }()
    let view2: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        return v
    }()
    let view3: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen
        return v
    }()

    return MyScrollableContainer(
        contents: [view1, view2, view3],
        scrollMode: .vertical
    )
}
