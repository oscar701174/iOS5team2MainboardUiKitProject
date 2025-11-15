//
//  VideoCell.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/9/25.
//

import UIKit

class VideoCell: UICollectionViewCell {
    static let reuseID = "VideoCell"

    let thumbImageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)

        // thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        contentView.preservesSuperviewLayoutMargins = false
        contentView.directionalLayoutMargins = .zero
        contentView.backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),

            thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),

            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            thumbImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            thumbImageView.widthAnchor.constraint(equalToConstant: 30),
            thumbImageView.heightAnchor.constraint(equalTo: thumbImageView.widthAnchor, multiplier: 9 / 16),

            titleLabel.topAnchor.constraint(equalTo: thumbImageView.bottomAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
    }

    override var isHighlighted: Bool {
        didSet {
            let transform: CGAffineTransform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95): .identity

            let alpha: CGFloat = isHighlighted ? 0.8 : 1.0

            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = transform
                self.contentView.alpha = alpha
            }
        }
    }

    func configure(with video: VideoEntity) {
        titleLabel.text = video.title ?? "제목없음"
        thumbImageView.image = UIImage(named: "sample")

        guard let url = VideoManager.bundleURLString(for: video) else {
            return
        }

        ThumnailManager.generateThumnail(from: url) { [weak self] image in
            guard let self else {
                return
            }

            self.thumbImageView.image = image ?? UIImage(named: "sample")
        }
    }
}

#Preview {
    MainViewController()
}
