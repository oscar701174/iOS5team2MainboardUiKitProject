//
//  MainViewController+CollectionView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit
import CoreData

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    private func resetPlayerUIForNewVideo() {

        let playButtonCFG = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        mainView.progressSlider.value = 0

        mainView.start.text = "00:00:00"
        didReachEnd = false

        mainView.playButton.setImage(UIImage(systemName: "play.fill",
                                             withConfiguration: playButtonCFG), for: .normal)

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count // 데이터 개수
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let raw = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseID, for: indexPath)
        guard let cell = raw as? VideoCell else { return raw }

        let video = videoList[indexPath.item]
        cell.configure(with: video)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                        withReuseIdentifier: "footer", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedVideo = videoList[indexPath.item]

        guard let url = VideoManager.bundleURLString(for: selectedVideo) else {
            print("잘못된 URL:", selectedVideo.url ?? "nil")
            return
        }

        resetPlayerUIForNewVideo()

        playingVideoURL = url

        playerManager.startPlayback(with: url)

        if let newPlayer = playerManager.player {
            self.player = newPlayer
            mainView.playerView.player = newPlayer
        }

        print("선택된 비디오 URL:", url)
    }

}

#Preview {
    MainViewController()
}
