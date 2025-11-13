//
//  MainLayout+VideoCollection.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/13/25.
//

import UIKit
import AVFoundation
import DropDown

extension MainLayout {

    func setVideoCollection() {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColor.background
        collectionView.showsVerticalScrollIndicator = false
        addSubview(collectionView)

        videoCollectionDefaultConstraints = [
            collectionView.topAnchor.constraint(equalTo: middleButtonStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        videoCollectionIPadLandscapeConstraints = [

            collectionView.leadingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: playerView.topAnchor),

            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            collectionView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -10)
        ]

        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        collectionView.layoutIfNeeded()
    }

    func updateFooterView(for traits: UITraitCollection) {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = collectionView.bounds.width
        if traits.userInterfaceIdiom == .pad {
            flow.footerReferenceSize = CGSize(width: width, height: width * 0.07)
        }
    }
}
