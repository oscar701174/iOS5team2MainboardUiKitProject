//
//  VideoCell.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/9/25.
//

import UIKit

/// # Overview
/// `UICollectionViewCell` 기반의 영상 목록 셀입니다.
/// 영상 썸네일과 제목을 보여주는 단순한 구성으로,  
/// `MainViewController`의 컬렉션뷰에서 사용됩니다.
///
/// # Responsibilities
/// - 영상 제목 표시
/// - 썸네일 이미지 로드 (`ThumbnailManager` 사용)
/// - 탭 시 가벼운 하이라이트 애니메이션 처리
///
/// # Usage
/// 컬렉션뷰에서 다음과 같이 셀을 구성합니다.
/// ```swift
/// func collectionView(_ collectionView: UICollectionView,
///                     cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
///     let cell = collectionView.dequeueReusableCell(
///         withReuseIdentifier: VideoCell.reuseID,
///         for: indexPath
///     ) as! VideoCell
///
///     cell.configure(with: video)
///     return cell
/// }
/// ```
class VideoCell: UICollectionViewCell {

    // MARK: - Identifier

    /// 컬렉션뷰 재사용을 위한 식별자
    static let reuseID = "VideoCell"

    // MARK: - UI Elements

    /// 영상 썸네일을 표시하는 이미지뷰
    let thumbImageView = UIImageView()

    /// 영상 제목 라벨
    let titleLabel = UILabel()

    // MARK: - Dependencies

    /// CoreData 기반 영상 데이터 관리 매니저
    private let videoManager = VideoManager(context: AppDelegate.viewContext)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    /// 셀 내부 UI 구성 요소를 초기화한다.
    private func setupUI() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)

        thumbImageView.clipsToBounds = true
        thumbImageView.contentMode = .scaleAspectFill

        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        contentView.backgroundColor = .clear
        contentView.preservesSuperviewLayoutMargins = false
        contentView.directionalLayoutMargins = .zero
    }

    /// Auto Layout 제약을 설정한다.
    private func setupLayout() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),

            thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            thumbImageView.widthAnchor.constraint(equalToConstant: 30),
            thumbImageView.heightAnchor.constraint(
                equalTo: thumbImageView.widthAnchor,
                multiplier: 9.0 / 16.0
            ),

            titleLabel.topAnchor.constraint(equalTo: thumbImageView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Cell Lifecycle

    /// 셀이 재사용되기 전에 호출되는 메서드로,
    /// 썸네일과 제목을 초기화한다.
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
    }

    /// 셀이 터치되었을 경우 강조 효과 제공
    override var isHighlighted: Bool {
        didSet {
            let transform = isHighlighted
                ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                : .identity

            let alpha: CGFloat = isHighlighted ? 0.8 : 1.0

            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = transform
                self.contentView.alpha = alpha
            }
        }
    }

    // MARK: - Configuration

    /// # Overview
    /// 셀에 표시할 영상 데이터를 구성한다.
    ///
    /// # Discussion
    /// - 제목을 바로 표시하고  
    /// - 비동기로 썸네일 이미지를 생성한 후 `thumbImageView`에 적용한다.
    ///
    /// # Parameter
    /// - `video`: CoreData의 `VideoEntity`
    func configure(with video: VideoEntity) {
        titleLabel.text = video.title

        guard let url = videoManager.bundleURL(for: video) else {
            return
        }

        ThumnailManager.generateThumnail(from: url) { [weak self] image in
            guard let self else { return }
            self.thumbImageView.image = image ?? UIImage(named: "sample")
        }
    }
}

#Preview {
    MainViewController()
}
