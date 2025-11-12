//
//  MainViewController+Search.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/11/25.
//

import AVFoundation
import UIKit

extension MainViewController: UISearchBarDelegate {

    func showSearchBar() {
        mainView.searchBar.becomeFirstResponder()
        mainView.searchBar.isHidden = false
        isSearchButtonActive = false
        mainView.searchBar.setShowsCancelButton(true, animated: true)
    }

    func hideSearchBar() {
        mainView.searchBar.resignFirstResponder()
        mainView.searchBar.text = ""
        mainView.searchBar.isHidden = true
        isSearchButtonActive = true
        mainView.searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
}
