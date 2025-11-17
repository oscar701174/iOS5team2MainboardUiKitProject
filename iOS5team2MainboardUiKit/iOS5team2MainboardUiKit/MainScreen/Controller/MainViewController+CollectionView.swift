//
//  MainViewController+CollectionView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit
import CoreData

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - UI Reset

    /// # Overview
    /// 새로운 영상 재생을 시작하기 전에 플레이어 UI를 초기 상태로 맞춥니다.
    ///
    /// # Discussion
    /// 영상이 변경될 때 기존 재생 상태가 그대로 남아 있으면
    /// UI가 뒤엉킬 수 있으므로, 다음 UI 요소를 초기 값으로 되돌립니다:
    /// - 재생 위치 슬라이더(0)
    /// - 시작 시간 라벨("00:00:00")
    /// - 재생 종료 플래그(`didReachEnd = false`)
    /// - 재생 버튼 아이콘을 `play.fill`로 설정
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

    // MARK: - Number of Items

    /// # Overview
    /// 현재 컬렉션뷰에서 보여줄 영상의 개수를 반환합니다.
    ///
    /// # Discussion
    /// 검색 중에는 `filteredVideos`,
    /// 그렇지 않은 경우 `videoList`를 데이터 소스로 사용합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 개수를 요청한 컬렉션뷰
    ///   - section: 섹션 인덱스
    /// - Returns: 해당 섹션에서 보여줄 셀의 개수
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        let dataSource = isSearching ? filteredVideos : videoList
        return dataSource.count
    }

    // MARK: - Cell Configuration

    /// # Overview
    /// 컬렉션뷰 셀을 구성하여 반환합니다.
    ///
    /// # Discussion
    /// 셀은 `VideoCell` 타입이며,
    /// `configure(with:)`를 호출하여 영상 정보를 적용합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 요청한 컬렉션뷰
    ///   - indexPath: 셀 위치
    /// - Returns: 구성된 셀 객체
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

    // MARK: - Supplementary Views

    /// # Overview
    /// 컬렉션뷰의 footer 등을 반환합니다.
    ///
    /// # Discussion
    /// 현재는 등록된 `"footer"`만 사용하며,
    /// 별도의 데이터 처리는 없습니다.
    ///
    /// - Parameters:
    ///   - collectionView: supplementary view를 요청한 컬렉션뷰
    ///   - kind: 뷰 종류(footer/header 등)
    ///   - indexPath: 위치
    /// - Returns: supplementary view 인스턴스
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "footer",
            for: indexPath
        )
    }

    // MARK: - Item Selection

    /// # Overview
    /// 영상 셀을 선택했을 때 해당 영상을 재생합니다.
    ///
    /// # Discussion
    /// 선택 시 다음 과정이 순서대로 실행됩니다:
    ///
    /// 1. **선택된 영상 엔티티 가져오기**
    /// 2. **영상 URL 확인 후 검증**
    /// 3. **플레이어 UI 초기화**
    /// 4. **현재 선택된 영상(selectedVideo) 저장**
    /// 5. **재생 버튼을 'play' 아이콘으로 초기화**
    /// 6. **영상 재생 시작 (VideoPlayerManager)**
    /// 7. **playerView에 새 AVPlayer 연결**
    ///
    /// 영상이 정상 로드되면 즉시 재생이 시작됩니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 선택한 컬렉션뷰
    ///   - indexPath: 선택된 셀 인덱스
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

        // 3. 현재 선택 영상 기록
        self.selectedVideo = selectedVideo
        playingVideoURL = url

        // 4. 재생 버튼 초기화
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
