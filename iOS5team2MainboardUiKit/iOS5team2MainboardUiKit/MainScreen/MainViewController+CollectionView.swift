//
//  MainViewController+CollectionView.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import UIKit

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 // 데이터 개수
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let raw = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseID, for: indexPath)
        guard let cell = raw as? VideoCell else { return raw }
        cell.configure( thumbnail: UIImage(named: "sample"),
                        title: "이것은 테스트를 위한 임시 문구 입니다. \(indexPath.item)"
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                        withReuseIdentifier: "footer", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        // playingVideoURL = selectedCell
    }

}
