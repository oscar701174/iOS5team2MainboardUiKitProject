//
//  MainViewController+Search.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import AVFoundation
import UIKit

extension MainViewController: UISearchBarDelegate {

    /// # Overview
    /// 검색 창(SearchBar)을 화면에 표시하고 입력을 받을 준비를 합니다.
    ///
    /// # Discussion
    /// - 검색창을 보여주고 키보드를 자동으로 올립니다.
    /// - 검색 버튼 활성 상태(`isSearchButtonActive`)를 false로 변경합니다.
    /// - Cancel 버튼을 표시하여 즉시 검색창을 닫을 수 있도록 합니다.
    func showSearchBar() {
        mainView.searchBar.becomeFirstResponder()
        mainView.searchBar.isHidden = false
        isSearchButtonActive = false
        mainView.searchBar.setShowsCancelButton(true, animated: true)
    }

    /// # Overview
    /// 검색 창(SearchBar)을 숨기고 검색 상태를 초기화합니다.
    ///
    /// # Discussion
    /// - 검색창을 숨기고 텍스트를 모두 지웁니다.
    /// - 검색 모드(`isSearching`)를 false로 전환합니다.
    /// - 필터링된 데이터 목록을 비우고 컬렉션 뷰를 새로고침합니다.
    func hideSearchBar() {
        mainView.searchBar.resignFirstResponder()
        mainView.searchBar.text = ""
        mainView.searchBar.isHidden = true
        isSearchButtonActive = true
        mainView.searchBar.setShowsCancelButton(true, animated: true)

        isSearching = false
        filteredVideos = []
        mainView.collectionView.reloadData()
    }

    /// # Overview
    /// 검색창의 Cancel 버튼을 눌렀을 때 호출됩니다.
    ///
    /// # Discussion
    /// `hideSearchBar()`를 호출하여 검색 상태를 모두 초기화합니다.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }

    /// # Overview
    /// 북마크 버튼(X 아이콘)을 눌렀을 때 검색 텍스트를 지웁니다.
    ///
    /// # Discussion
    /// 검색 자체를 종료하지 않고 단순히 텍스트만 초기화합니다.
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }

    /// # Overview
    /// 검색창 텍스트가 변경될 때마다 호출되는 메서드입니다.
    ///
    /// # Discussion
    /// 검색어 공백/줄바꿈을 제거한 뒤 빈 문자열인지 확인해
    /// 검색 모드 여부를 결정합니다.
    ///
    /// 검색어가 존재하면 다음 기준으로 필터링합니다:
    /// - 영상 제목이 검색어를 **대소문자 구분 없이 포함하는지**
    ///
    /// - Parameters:
    ///   - searchBar: 텍스트 변경이 발생한 검색창
    ///   - searchText: 사용자가 현재 입력 중인 텍스트
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            isSearching = false
            filteredVideos = []
        } else {
            isSearching = true
            filteredVideos = videoList.filter { video in
                let title = video.title ?? ""
                return title.localizedCaseInsensitiveContains(trimmed)
            }
        }

        mainView.collectionView.reloadData()
    }
}
