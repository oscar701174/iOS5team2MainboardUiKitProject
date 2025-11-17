//
//  MainViewController+CollectionView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit
import CoreData

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    /// # Overview
    /// 새로운 영상을 선택했을 때 플레이어 UI를 초기 상태로 초기화합니다.
    ///
    /// # Discussion
    /// 다음과 같은 UI 요소들을 기본값으로 되돌립니다.
    /// - 슬라이더 위치(0)
    /// - 재생 시간 라벨("00:00:00")
    /// - 재생 종료 여부 플래그
    /// - 재생 버튼 아이콘을 `play.fill`로 변경
    func resetPlayerUIForNewVideo() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        mainView.progressSlider.value = 0
        mainView.start.text = "00:00:00"
        didReachEnd = false

        mainView.playButton.setImage(
            UIImage(systemName: "play.fill", withConfiguration: cfg),
            for: .normal
        )
    }

    /// # Overview
    /// 컬렉션뷰에 표시할 영상의 개수를 반환합니다.
    ///
    /// # Discussion
    /// 검색 모드(`isSearching`)에 따라 데이터 소스가 다음 중 하나로 결정됩니다:
    /// - `filteredVideos`
    /// - `videoList`
    ///
    /// - Parameters:
    ///   - collectionView: 현재 컬렉션뷰
    ///   - section: 섹션 인덱스
    ///
    /// - Returns: 해당 섹션에서 보여줄 셀의 수
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let dataSource = isSearching ? filteredVideos : videoList
        return dataSource.count
    }

    /// # Overview
    /// 컬렉션뷰의 각 셀을 구성하여 반환합니다.
    ///
    /// # Discussion
    /// 셀은 `VideoCell` 타입이며,
    /// `configure(with:)` 메서드를 통해 영상 정보를 UI에 반영합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 요청한 컬렉션뷰
    ///   - indexPath: 셀 위치
    ///
    /// - Returns: 구성된 `UICollectionViewCell`
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let raw = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCell.reuseID,
            for: indexPath
        )

        guard let cell = raw as? VideoCell else { return raw }

        let dataSource = isSearching ? filteredVideos : videoList
        let video = dataSource[indexPath.item]

        cell.configure(with: video)
        return cell
    }

    /// # Overview
    /// 컬렉션뷰의 footer 또는 기타 supplementary view를 반환합니다.
    ///
    /// # Discussion
    /// 현재는 등록된 `"footer"` 뷰만 반환하며,
    /// 특별한 로직 없이 뷰만 전달합니다.
    ///
    /// - Parameters:
    ///   - collectionView: supplementary view를 요청한 컬렉션뷰
    ///   - kind: 뷰 종류(footer/header 등)
    ///   - indexPath: 위치
    ///
    /// - Returns: 등록된 supplementary view
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "footer",
            for: indexPath
        )
    }

    /// # Overview
    /// 영상 셀을 선택했을 때 해당 영상을 재생합니다.
    ///
    /// # Discussion
    /// 선택된 영상에 대해 다음 작업이 수행됩니다:
    /// 1. 영상 URL 확인  
    /// 2. 플레이어 UI 초기화  
    /// 3. `selectedVideo`에 현재 영상 저장  
    /// 4. 재생 버튼을 초기 아이콘으로 설정  
    /// 5. `VideoPlayerManager`를 통해 재생 시작  
    /// 6. `playerView`에 새로운 AVPlayer 연결  
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 선택한 컬렉션뷰
    ///   - indexPath: 선택된 셀의 위치
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let dataSource = isSearching ? filteredVideos : videoList
        let selectedVideo = dataSource[indexPath.item]
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        // 1. 영상 URL 조회
        guard let url = videoManager.bundleURL(for: selectedVideo) else {
            print("잘못된 URL:", selectedVideo.url ?? "nil")
            return
        }

        // 2. UI 초기화
        resetPlayerUIForNewVideo()

        // 3. 현재 선택된 엔티티 저장
        self.selectedVideo = selectedVideo
        playingVideoURL = url

        // 4. 재생 버튼 아이콘 초기화
        mainView.playButton.setImage(
            UIImage(systemName: "play.fill", withConfiguration: cfg),
            for: .normal
        )

        // 5. 재생 시작
        playerManager.startPlayback(with: url)

        // 6. playerView 업데이트
        if let newPlayer = playerManager.player {
            mainView.playerView.player = newPlayer
        }

        print("선택된 비디오 URL:", url)
    }
}

#Preview {
    MainViewController()
}
