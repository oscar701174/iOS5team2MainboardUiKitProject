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

    /// 영상 목록을 표시하는 `UICollectionView`를 구성합니다.
    ///
    /// 기본적으로 세로 스크롤 형태의 단일 컬럼 레이아웃을 사용하며,  
    /// iPad 가로 모드에서는 상단 플레이어 옆에 배치될 수 있도록  
    /// 별도의 제약 조건 세트를 준비합니다.
    ///
    /// - 설정 요소:
    ///   - `UICollectionViewFlowLayout` 기본값 적용  
    ///   - 셀 및 푸터 등록  
    ///   - iPhone / iPad 레이아웃 대응을 위한 제약 생성
    func setVideoCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColor.background
        collectionView.showsVerticalScrollIndicator = false

        addSubview(collectionView)

        // 기본(iPhone 세로 기준) 레이아웃 제약
        videoCollectionDefaultConstraints = [
            collectionView.topAnchor.constraint(equalTo: middleButtonStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        // iPad 가로 모드 전용 제약
        videoCollectionIPadLandscapeConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: playerView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            collectionView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -10)
        ]

        // 셀 및 푸터 등록
        collectionView.register(
            VideoCell.self,
            forCellWithReuseIdentifier: VideoCell.reuseID
        )

        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
        )

        collectionView.layoutIfNeeded()
    }

    /// 디바이스 환경에 따라 컬렉션뷰 footer의 크기를 업데이트합니다.
    ///
    /// - Parameter traits: 현재 뷰의 `UITraitCollection`
    ///
    /// iPad 환경에서는 footer를 더 작게 설정하여
    /// 넓은 화면 구조에 맞는 배치를 제공합니다.
    func updateFooterView(for traits: UITraitCollection) {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let width = collectionView.bounds.width

        if traits.userInterfaceIdiom == .pad {
            flow.footerReferenceSize = CGSize(width: width, height: width * 0.07)
        }
    }
}

#Preview {
    MainViewController()
}
