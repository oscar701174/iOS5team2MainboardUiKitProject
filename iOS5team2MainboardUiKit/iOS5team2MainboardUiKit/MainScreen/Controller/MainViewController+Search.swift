//
//  MainViewController+Search.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import AVFoundation
import UIKit

extension MainViewController: UISearchBarDelegate {

    // MARK: - Show Search Bar

    /// # Overview
    /// 검색창을 화면에 표시하고 입력을 받을 준비를 합니다.
    ///
    /// # Discussion
    /// - 검색창을 보이게 하고 키보드를 자동으로 올립니다.
    /// - 검색 버튼 상태(`isSearchButtonActive`)를 false로 변경합니다.
    /// - Cancel 버튼을 표시하여 즉시 검색을 종료할 수 있도록 합니다.
    func showSearchBar() {
        mainView.searchBar.isHidden = false
        mainView.searchBar.becomeFirstResponder()
        mainView.searchBar.setShowsCancelButton(true, animated: true)
        isSearchButtonActive = false
    }

    // MARK: - Hide Search Bar

    /// # Overview
    /// 검색창을 숨기고 검색과 관련된 상태를 모두 초기화합니다.
    ///
    /// # Discussion
    /// - 검색창을 닫고 입력된 텍스트를 제거합니다.
    /// - 검색 모드(`isSearching`)를 false로 설정합니다.
    /// - 필터링된 데이터(`filteredVideos`)를 비운 뒤 컬렉션뷰를 다시 로드합니다.
    func hideSearchBar() {
        mainView.searchBar.text = ""
        mainView.searchBar.resignFirstResponder()
        mainView.searchBar.isHidden = true
        mainView.searchBar.setShowsCancelButton(false, animated: true)

        isSearchButtonActive = true
        isSearching = false
        filteredVideos = []
        mainView.collectionView.reloadData()
    }

    // MARK: - Cancel Button

    /// # Overview
    /// 검색창의 Cancel 버튼을 눌렀을 때 호출됩니다.
    ///
    /// # Discussion
    /// 사용자가 “검색 종료”를 명확히 요청한 것으로 간주하고,
    /// `hideSearchBar()`를 호출하여 검색 상태를 모두 되돌립니다.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }

    // MARK: - Bookmark (Clear Text) Button

    /// # Overview
    /// 검색창의 북마크 버튼(일반적으로 X 아이콘)을 눌러 텍스트를 지웁니다.
    ///
    /// # Discussion
    /// 검색창을 완전히 닫지 않고,
    /// 단순히 입력된 텍스트만 초기화하고 계속 검색을 진행할 수 있도록 합니다.
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }

    // MARK: - Real-Time Search

    /// # Overview
    /// 사용자가 검색창에 텍스트를 입력할 때마다 호출됩니다.
    ///
    /// # Discussion
    /// - 공백을 제거한 실제 검색어(`trimmed`)가 비어 있는지 판단하여
    ///   검색 모드(`isSearching`) 상태를 결정합니다.
    /// - 검색어가 존재하면 영상 제목(title)을 기준으로
    ///   **대소문자 구분 없이 포함 여부**를 검사해 필터링합니다.
    ///
    /// - Parameters:
    ///   - searchBar: 텍스트가 변경된 검색창
    ///   - searchText: 변경된 텍스트 값
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

    // MARK: - Search Button (Return Key)

    /// # Overview
    /// 키보드의 “검색” 버튼(Return)을 눌렀을 때 호출됩니다.
    ///
    /// # Discussion
    /// 검색어 입력을 마무리하고 키보드를 내리는 역할을 합니다.
    /// 검색 동작 자체는 textDidChange에서 이미 처리되므로
    /// 여기서는 포커스만 제거합니다.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
