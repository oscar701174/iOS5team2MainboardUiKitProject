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

    // MARK: - CollectionView Layout Setup

    /// # Overview
    /// 영상 목록을 표시하는 `UICollectionView`를 초기 구성합니다.
    ///
    /// # Discussion
    /// 기본적으로 단일 컬럼의 세로 스크롤 레이아웃을 사용하며,
    /// iPad 가로 모드에서는 **상단 플레이어 오른쪽에 위치하는 2-패널 구조**를 이루기 위해
    /// 전용 제약(`videoCollectionIPadLandscapeConstraints`)을 따로 준비합니다.
    ///
    /// 이 구성 함수에서는 다음을 수행합니다:
    /// - `UICollectionViewFlowLayout` 생성 및 기본 설정
    /// - 컬렉션뷰 등록 및 배경색 지정
    /// - iPhone / iPad 대응 제약 생성
    /// - 셀 및 footer 뷰 등록
    ///
    /// - Note:
    ///   컬렉션뷰는 MainViewController에서 DataSource/Delegate가 설정됩니다.
    func setVideoCollection() {

        // MARK: 레이아웃 생성
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        // MARK: CollectionView 생성
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColor.background
        collectionView.showsVerticalScrollIndicator = false

        addSubview(collectionView)

        // MARK: iPhone / iPad 세로 기본 제약
        /// 기본적으로 플레이어 아래쪽에 컬렉션뷰가 배치되는 단일 컬럼 구조
        videoCollectionDefaultConstraints = [
            collectionView.topAnchor.constraint(equalTo: middleButtonStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        // MARK: iPad 가로 전용 제약
        /// iPad 가로에서는 플레이어가 왼쪽, 컬렉션뷰가 오른쪽에 배치되어
        /// 더 넓은 화면에서 양쪽에 콘텐츠가 충분히 노출되도록 구성합니다.
        videoCollectionIPadLandscapeConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: playerView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            collectionView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -10)
        ]

        // MARK: 셀 및 푸터 등록
        collectionView.register(
            VideoCell.self,
            forCellWithReuseIdentifier: VideoCell.reuseID
        )

        /// footer 등록 → 섹션 하단의 공백 역할
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
        )

        // 초기 레이아웃 계산
        collectionView.layoutIfNeeded()
    }

    // MARK: - Footer Size Update

    /// # Overview
    /// 디바이스 환경(iPhone / iPad)에 따라 컬렉션뷰 footer 높이를 업데이트합니다.
    ///
    /// # Discussion
    /// Footer는 섹션 하단에 표시되는 “여백 역할”의 뷰이며,
    /// iPad에서는 화면이 넓기 때문에 footer의 높이를 더 작게 설정하여
    /// 불필요한 공간 낭비를 줄이는 방식으로 구성합니다.
    ///
    /// - Parameter traits: 현재 뷰의 `UITraitCollection`
    func updateFooterView(for traits: UITraitCollection) {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let width = collectionView.bounds.width

        if traits.userInterfaceIdiom == .pad {
            /// iPad → footer를 더 작은 값으로 설정
            flow.footerReferenceSize = CGSize(width: width, height: width * 0.07)
        }
    }
}

#Preview {
    MainViewController()
}
